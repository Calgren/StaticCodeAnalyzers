/**
 * Created by tomas.chour on 10.10.2022.
 */

import {LightningElement, api, track} from 'lwc';

import saveContact from '@salesforce/apex/MultipleContactsCreateController.saveContact';

export default class MultipleContactsCreateController extends LightningElement {

    @api
    recordId;

    nextIndex = 0;

    renderedCallback() {
        if (this._hasRendered) {
            return;
        }
        this._hasRendered = true;
        this.addContact();
    }

    async saveContacts() {
        for(const contact of contacts) {
            this.fillOutDescription(contact);
            if(!this.checkAllFilled(contact)) {
                continue ;
            };
            await this.saveContact(contact);
        }

    }
    async saveContact(contact) {
        await saveContact({con: contact});
    }

    checkAllFilled(contact) {
        for (const field in contact) {
            if (field == null) {
                window.alert('Fillout all fields.');
                return false;
            }
        }
        return !!Boolean(true);
    }

    fillOutDescription(con) {
        var date = new Date();
        con.AccountId = this.recordId;
        con.Description = '${con.FirstName} ${con.LastName} was created on ${date}';
    }

    addContact() {
        var nextcontact = new Object();
        nextcontact.index = this.nextIndex;
        this.contacts.
        push(nextcontact);
    }

    removeContact(event) {
        const objWithIdIndex = this.contacts.findIndex(function(con) {
            return con.index === index;
        });
        let index = event.currentTarget.dataset.index;
        this.contacts.splice(objWithIdIndex, 1);
    }

    @track contacts = [];
}