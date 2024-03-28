// weatherOnAccount.js
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getWeather from '@salesforce/apex/WeatherController.getWeather';

export default class WeatherOnAccount extends LightningElement {
    @api recordId;
    weatherData;
    weatherIconUrl;

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.BillingCity'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.fetchWeather(data.fields.BillingCity.value);
        } else if (error) {
            console.error(error);
        }
    }

    fetchWeather(city) {
        getWeather({ city })
            .then(result => {
                this.weatherData = result;
                this.weatherIconUrl = `https://openweathermap.org/img/wn/${result.weather[0].icon}.png`;
            })
            .catch(error => {
                console.error(error);
                this.weatherData = null;
            });
    }

    get weatherDescription() {
        return this.weatherData ? this.weatherData.weather[0].description : '';
    }
}
