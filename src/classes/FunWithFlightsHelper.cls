/**
 * Created by oleg_zykyi on 9/5/22.
 */

public without sharing class FunWithFlightsHelper {

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled
    public static List<LookupSearchResult> searchAirports(String searchTerm, List<String> selectedIds) {

        searchTerm += '*';

        List<List<SObject>> searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                        RETURNING
                        Airport__c(Id, Name WHERE id NOT IN :selectedIds)
                LIMIT :MAX_RESULTS
        ];

        List<LookupSearchResult> results = new List<LookupSearchResult>();

        String airportIcon = 'utility:agent_home';

        List<Airport__c> airports = (List<Airport__c>) searchResults[0];
        for (Airport__c airport : airports) {

            String subtitle = 'Airport';
            results.add(new LookupSearchResult(airport.Id, 'Account__c', airportIcon, airport.Name, subtitle));
        }

        return results;
    }

    @AuraEnabled
    public static List<Flight> searchFlights(String sourceAirport, String destinationAirport) {

        if(sourceAirport == null && destinationAirport == null) {

            throw new AuraHandledException('Error. At least one airport should be provided.');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(generateEndpoint(sourceAirport, destinationAirport));
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(req);

        List<Flight> flights;

        if(response.getStatusCode() == 200) {

            flights = (List<Flight>) JSON.deserialize(response.getBody(), List<Flight>.class);
            return flights;
        }

        throw new AuraHandledException('Unable to load data from providers: ' + response.getStatus());
    }

    private static String generateEndpoint(String sourceAirport, String destinationAirport) {

        String endpoint = 'callout:Mule_Flights_API/routes?';

        if(sourceAirport != null) {

            endpoint += 'source=' + sourceAirport;
        }

        if(destinationAirport != null) {

            if(endpoint.contains('source')) {

                endpoint += '&';
            }
            endpoint += 'dest=' + destinationAirport;
        }

        return endpoint;
    }


    public class Flight {

        @AuraEnabled
        public String airline {get; set;}
        @AuraEnabled
        public String sourceAirport {get; set;}
        @AuraEnabled
        public String destinationAirport {get; set;}
        @AuraEnabled
        public String codeShare {get; set;}
        @AuraEnabled
        public String stops {get; set;}
        @AuraEnabled
        public String equipment {get; set;}
    }

}