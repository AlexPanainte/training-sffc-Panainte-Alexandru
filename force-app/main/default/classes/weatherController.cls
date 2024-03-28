public with sharing class WeatherController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWeather(String city) {
        // Callout to OpenWeatherMap API
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.openweathermap.org/data/2.5/weather?q=' + EncodingUtil.urlEncode(city, 'UTF-8') + '&appid=YOUR_API_KEY&units=metric');
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        } else {
            throw new AuraHandledException('Error fetching weather data');
        }
    }
}
