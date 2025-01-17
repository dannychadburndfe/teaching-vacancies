import axios from 'axios';
import logger from './logging';

export const getPostcodeFromCoordinates = (latitude, longitude) => axios.get('https://api.postcodes.io/postcodes', {
  params: { latitude, longitude },
}).then((response) => response.data.result[0].postcode)
  .catch((error) => {
    logger.log(`${error} Postcodes API`);
  });

export const getLocationSuggestions = ({ query, populateResults }) => axios.get(`/api/v1/location_suggestion/${query}?format=json`)
  .then((response) => response.data)
  .then((data) => data.suggestions)
  .then(populateResults)
  .catch((error) => {
    logger.log(`${error} Search query: ${query}`);
  });

export const getMapData = (items) => Promise.all(items.map((item) => api[`${item.type}Request`](item.params)))
  .then((data) => data.reduce((a, b) => a.concat(b), []));

export const locationRequest = ({ location, radius }) => axios.get(`/api/v1/map/locations/${location}?radius=${radius}&format=json`)
  .then((response) => response.data)
  .catch((error) => {
    logger.log(error);
  });

export const vacancyRequest = ({ id }) => axios.get(`/api/v1/map/vacancies/${id}?format=json`)
  .then((response) => response.data)
  .catch((error) => {
    logger.log(error);
  });

const api = {
  getPostcodeFromCoordinates,
  getLocationSuggestions,
  getMapData,
  locationRequest,
  vacancyRequest,
};

export default api;
