const fs = require("fs");
const fetch = require("node-fetch");

const ROUTE_TIMETABLE_COUNT = parseInt(process.env.ROUTE_TIMETABLE_LIMIT) || 0;

const DIGITRANSIT_API_URL = process.env.DIGITRANSIT_API_URL || "https://api.digitransit.fi";

const API_URL = `${DIGITRANSIT_API_URL}/routing/v1/routers/hsl/index/graphql`;

const TAKU_API_URL = "https://taku.hsl.fi/fi/aikataulu";

// base64 encoded basic auth
const TAKU_KEY = process.env.TAKU_KEY;

// get all route gtfsId values
async function fetchRouteIds() {
    const options = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ query: "query routes {routes { gtfsId }}" }),
    };

    const response = await fetch(API_URL, options);
    const json = await response.json();
    return json.data.routes;
}


// get link to timetable and fetch it. returns promise that resolves with object that has gtfsId key and download success status
async function fetchRouteTimetable(routeId) {
    const options = {
        method: "GET",
        headers: { "Authorization": `Basic ${TAKU_KEY}` },
    };

    // success 0 == no pdf download link, success == 1 pdf link but download failed, success == 3 download succeeded
    let routeStatus = {routeId: routeId, success: 0};
    return new Promise((resolve, reject) => {
        fetch(`${TAKU_API_URL}/${routeId}/`, options)
        .then(res => res.json())
        .then(json => {
            if (json.status == "success") {
                // download link for pdf
                const pdfLocation = json.results.pdf;
                fetch(pdfLocation)
                .then((res) => {
                    if (res.ok) {
                        const dest = fs.createWriteStream(`./output-routes/${routeId}.pdf`);
                        res.body.pipe(dest);
                        // Unless any error is thrown later on, download should be successful
                        routeStatus.success = 2;
                        resolve(routeStatus);
                    } else {
                        console.error(`Downloading route timetable pdf for ${routeId} failed: ${res.statusText}`);
                        // downloading returned something else than 200
                        routeStatus.success = 1;
                        resolve(routeStatus);
                    }
                })
                .catch(err => {
                    // Error occured while downloading pdf
                    routeStatus.success = 1;
                    console.error(`Downloading route timetable pdf for ${routeId} failed: ${err}`);
                    resolve(routeStatus);
                })
            } else {
                // No download link for pdf
                console.error(`Downloading route timetable location for ${routeId} failed: ${json.message}`);
                resolve(routeStatus);
            }
        })
        .catch(err => {
            // error occured while downloading pdf link
            console.error(`Downloading route timetable location for ${routeId} failed: ${err}`);
            resolve(routeStatus);
        });
    });
}

async function getFetchStatuses(routeIds) {
    let routeFetchResults = {};

    const limit = ROUTE_TIMETABLE_COUNT == 0 ? routeIds.length : ROUTE_TIMETABLE_COUNT;
    for (let i = 0; i < limit; i++) {
        // Remove HSL:
        const routeId = routeIds[i].gtfsId.substring(4);
        // Synchronously download pdfs to avoid failures
        const result = await fetchRouteTimetable(routeId);
        routeFetchResults[result.routeId] = result;
    }
    
    return routeFetchResults;
}

if (!fs.existsSync("/opt/publisher/output-routes/")){
    fs.mkdirSync("/opt/publisher/output-routes/");
}

fetchRouteIds()
.then((routeIds) => {
    getFetchStatuses(routeIds)
    .then((statuses) => {
        const filteredObjects = {};
        const totalCount = Object.keys(statuses).length;
        let successfulCount = 0;
        for (const id of Object.keys(statuses)) {
            const item = statuses[id];
            // if could not find a download link for route and there is a pdf for route which first 4 numbers are the same
            if (item.success == 0 && id.length > 4 && id.substring(0, 3) in statuses && statuses[id.substring(0, 3)].success == 2) {
                console.log(`mapping ${id} to ${id.substring(0, 3)}`);
                // link routes id to id of the pdf that contains its timetables
                filteredObjects[id] = id.substring(0, 3);
                successfulCount += 1;
            } else if (item.success == 2) {
                filteredObjects[id] = id;
                successfulCount += 1;
            }
        }
        const failCount = totalCount - successfulCount;
        const json = JSON.stringify(filteredObjects);
        // store routeId: actualIdForPdf mapping so that UI can give users right links
        fs.writeFile('/opt/publisher/output-routes/routes.json', json, 'utf8', (err) => {
            if (err) console.log(err);
        });
        console.log(`generateRouteTimetables finished ${totalCount} routes ${successfulCount} successful ${failCount} failed`);
    })
});
