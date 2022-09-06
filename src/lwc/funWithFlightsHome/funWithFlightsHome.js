/**
 * Created by oleg_zykyi on 9/4/22.
 */

import {LightningElement, track} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

import searchAirports from '@salesforce/apex/FunWithFlightsHelper.searchAirports';
import searchFlights from '@salesforce/apex/FunWithFlightsHelper.searchFlights';

export default class FunWithFlightsHome extends LightningElement {

    @track fromErrors = [];
    @track toErrors = [];

    flights = [];

    isLoading = false;
    flightsFound = false;
    displayNotFoundMessage = false;

    search() {

        this.isLoading = true;
        this.displayNotFoundMessage = false;
        this.flightsFound = false;
        this.fromErrors = [];
        this.toErrors = [];

        const fromLookup = this.template.querySelector(".c-from-lookup").getSelection();
        const toLookup = this.template.querySelector(".c-to-lookup").getSelection();

        if (fromLookup.length > 0 || toLookup.length > 0) {

            searchFlights({sourceAirport: fromLookup[0]?.title || null, destinationAirport: toLookup[0]?.title || null})
                .then(result => {

                    this.flights = result;
                    if (this.flights.length > 0) {
                        this.flightsFound = true;
                    } else {

                        this.displayNotFoundMessage = true;
                    }
                    this.isLoading = false;
                }).catch(error => {

                console.log(error);
                this.isLoading = false;
            })
        } else {

            this.isLoading = false;

            this.fromErrors.push({message: 'Enter source airport'});
            this.toErrors.push({message: 'Enter destination airport'});

        }
    }

    handleLookupSearch(event) {
        const lookupElement = event.target;

        searchAirports(event.detail)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');

                console.error('Lookup error', JSON.stringify(error));
            });
    }

    handleLookupSelectionChange(event) {
        this.fromErrors = [];
        this.toErrors = [];
    }

    notifyUser(title, message, variant, mode) {

        dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            })
        );
    }

}