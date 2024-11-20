const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');

// Estendi dayjs con i plugin
dayjs.extend(utc);
dayjs.extend(timezone);

module.exports = dayjs;
