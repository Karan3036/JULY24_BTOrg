import { LightningElement, api, track } from 'lwc';
import getDataFromFolder from '@salesforce/apex/displayPublicFolderCls.getDataFromFolder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DisplayPublicFolderLWC extends LightningElement {
    @api folderId;

    @track showspinner = false;
    @track folderWrap = {};
    @track noFiles = false;

    connectedCallback(){
        console.log('folderId ==> '+this.folderId);
        this.showspinner = true;

        getDataFromFolder({
                recId: this.folderId
            })
            .then(result => {
                console.log('Result ==> ',result);
                this.folderWrap = result;

                if (result.publicFolder.buildertek__File_Count__c == 0) {
                    this.noFiles = true;
                }

                this.showspinner = false;
            })
            .catch(error => {
                console.error('Error => ',error);
                this.showspinner = false;
                alert('Something Went Wrong.');
            });

    }

}