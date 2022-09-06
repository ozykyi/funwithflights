/**
 * Created by oleg_zykyi on 9/6/22.
 */

@IsTest
private class FunWithFlightsHelper_Test {

    @isTest private static void searchAirportsTest() {

        List<Id> fixedResults = new List<Id>();

        Airport__c airportAAA = new Airport__c(Name = 'AAA');
        Airport__c airportAAB = new Airport__c(Name = 'AAB');

        insert new List<Airport__c>{airportAAA, airportAAB};

        fixedResults.add(airportAAA.Id);
        fixedResults.add(airportAAB.Id);

        Test.setFixedSearchResults(fixedResults);

        List<LookupSearchResult> searchResults;

        Test.startTest();

        searchResults = FunWithFlightsHelper.searchAirports('AA', new List<String>());

        Test.stopTest();

        System.assertEquals(2, searchResults.size(), 'Both airports should be returned by the search term');
    }

    @isTest private static void searchFlightsBadInputTest() {

        Test.setMock(HttpCalloutMock.class, new SearchFlightsMockResponseSuccess());

        Boolean isException;

        Test.startTest();

        try {

            FunWithFlightsHelper.searchFlights(null, null);
        } catch (AuraHandledException ex) {

            isException = true;
        }

        Test.stopTest();

        System.assert(isException, 'No input parameters, exception should be thrown');
    }

    @isTest private static void searchFlightsSuccessTest() {

        // cover DTO by the the test
        FunWithFlightsHelper.Flight flight = new FunWithFlightsHelper.Flight();
        flight.airline = 'GL';
        flight.sourceAirport = 'AAA';
        flight.destinationAirport = 'AAB';
        flight.codeShare = '35';
        flight.stops = '1';
        flight.equipment = '737';

        Test.setMock(HttpCalloutMock.class, new SearchFlightsMockResponseSuccess());

        List<FunWithFlightsHelper.Flight> flights;

        Test.startTest();

        flights = FunWithFlightsHelper.searchFlights('ASF', 'MRV');

        Test.stopTest();

        System.assertEquals(1, flights.size(), 'One flight should be returned');
    }

    @isTest private static void searchFlightsFailTest() {


        Test.setMock(HttpCalloutMock.class, new SearchFlightsMockResponseFail());

        Boolean isException;

        Test.startTest();

        try {

            FunWithFlightsHelper.searchFlights('ASF', 'MRV');
        } catch (AuraHandledException ex) {

            isException = true;
        }

        Test.stopTest();

        System.assert(isException, 'Not available, exception should be thrown');
    }

    public class SearchFlightsMockResponseSuccess implements HttpCalloutMock {

        public HttpResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setBody('[{\n' +
                    '    "airline": "2B",\n' +
                    '    "sourceAirport": "ASF",\n' +
                    '    "destinationAirport": "MRV",\n' +
                    '    "codeShare": "",\n' +
                    '    "stops": 0,\n' +
                    '    "equipment": "CR2"\n' +
                    '  }]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class SearchFlightsMockResponseFail implements HttpCalloutMock {

        public HttpResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setBody('[]');
            res.setStatusCode(500);
            return res;
        }
    }

}