const fs = require("fs");
const { fetchStopIds } = require("./scripts/stops");
const generator = require("./scripts/generator");

async function generateStopTimetables(representativeDate, forceStopIds) {
    const stopIds = forceStopIds || await fetchStopIds();
    return Promise.all(stopIds.slice(0,500).map(stopId => generator.generate({
        id: stopId,
        component: "Timetable",
        props: { stopId, date: representativeDate, printTimetablesAsA4: true },
        onInfo: s => console.log("info on ", stopId, ":", s),
        onError: (err) => { console.log("error on", stopId); console.error(err); },
    })));
}



const today = new Date().toISOString().substr(0, 10);

const representativeDate = process.argv.length > 2 ? process.argv[2] : today;
let forceStopIds = process.argv.length > 3 ? process.argv[3] : null;

if (forceStopIds) {
    if (fs.existsSync(forceStopIds)) {
        forceStopIds = fs.readFileSync(forceStopIds, { encoding: "utf-8" }).split(/(\D)/).map(parseFloat).filter(id => !Number.isNaN(id));
    } else {
        console.log("raw", forceStopIds);
        console.log("splitted", forceStopIds.split(/(\D)/));
        console.log("parsed", forceStopIds.split(/(\D)/).map(parseFloat));
        forceStopIds = forceStopIds.split(/(\D)/).map(parseFloat).filter(id => !Number.isNaN(id));
    }
}

generateStopTimetables(representativeDate, forceStopIds).then((res) => {
    console.log("generateStopTimetables", "finished", res.length, "stops", res.filter(r => r.success).length, "successful", res.filter(r => !r.success).length, "failed");
    process.exit(0);
}).catch(console.error);
