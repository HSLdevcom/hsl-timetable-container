# HSL-TIMETABLE-CONTAINER (BUILDER)  

This repository is used for generating stop timetables and fetching route timetables. This builds into a hsl-timetable-builder image and that image is used to build hsl-timetable-container images. This project uses docker image built from https://github.com/hsldevcom/hsl-map-publisher. Everytime something is changed within this project, we get the latest updates from the hsl-map-publisher project.

## Configuration env variables

* DIGITRANSIT_API_URL - defines base URL for digitransit API, defaults to https://api.digitransit.fi
* TAKU_KEY - base64 encoded basic authentication key, mandatory for fetching route timetables
* ROUTE_TIMETABLE_COUNT - debugging parameter for limiting how many route timetables are fetched
* FONTSTACK_PASSWORD - fontstack password used for generating stop timetables
* STOP_TIMETABLE_LIMIT - debugging parameter for limiting how many stop timetables are generated
* TIMETABLE_DAYS_ADVANCE - can be used to generate timetables that are valid in x days instead of those that are valid now, defaults to 0
* DOCKER_USER - username for docker account used for pushing new images
* DOCKER_AUTH - password for docker account used for pushing new images
* DOCKER_TAG - New images are deployed with this docker image tag
* SLACK_WEBHOOK_URL - Slack webhook URL for sending slack messages
* AUTHENTICATION_HEADER - header used for authenticating calls to routing API
* AUTHENTICATION_TOKEN - value for the authentication header for calls to routing API
