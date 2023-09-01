import { LightningElement, track, wire, api } from 'lwc';
import  getContentDocuments from "@salesforce/apex/PublicFileShareController.getContentDocuments";
import getFolderList from "@salesforce/apex/PublicFileShareController.getFolderList";
import createPublicFolder from "@salesforce/apex/PublicFileShareController.createPublicFolder";
import {NavigationMixin} from 'lightning/navigation'

export default class PublicFileShareLWC extends NavigationMixin(LightningElement) {

    @api recordId; // Passed record ID
    @track spinnerDataTable = true;

    @track contentDocuments = [] ; // All content documents
    @track selectedDocuments = []; // Selected documents
    @track folderData = [];
    @track selectedFolderData = [];

    @track showfiles = false;
    @track showfolders = true;
    @track showNewFolderPopup = false;

    @track newFolderName = '';
    @track newFolderDescription = '';

    columns = [
        // { label: 'Id', fieldName: 'Id' }
        { label: 'Select', type: 'radio', typeAttributes: { label: '', name: 'radio', value: 'id', disabled: false } },
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Description', fieldName: 'buildertek__Description__c', type: 'text' },
        { label: 'File Count', fieldName: 'buildertek__File_Count__c', type: 'number' },
        // { label: 'URL', type: 'url', fieldName: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' } }
    ];

    connectedCallback() {
        // Fetch content documents for the passed record ID
        try {
            this.getFolderDataFromApex()            
        } catch (error) {
            console.error(error);
        }
    }

    getFolderDataFromApex(){
        // this.showNewFolderPopup = false
        getFolderList()
            .then((response) =>{
                console.log("FolderData:- ",response);
                this.folderData = response;
                this.spinnerDataTable = false
            });
    }

    getFilesforselectedRecord(){
        getContentDocuments({recordId:this.recordId})
            .then ((response) =>{
                console.log(response)
                console.log(typeof(response))
                const arrayOfObj = Object.values(response);
                console.log("arrayOfObj :- ",arrayOfObj)

                this.contentDocuments = arrayOfObj;
                console.log("ContentDocuments :- ",this.contentDocuments)
                this.spinnerDataTable = false
            });
    }

    handleCheckboxChange(event) {
        const selectedDocId = event.target.value;
        const isChecked = event.target.checked;
        console.log('selectedDocId :- ',selectedDocId)

        if (isChecked) {
            console.log('isChecked in IF :- ', isChecked);
            this.contentDocuments.forEach(element => {
                console.log(JSON.stringify(element))
                if(element.ContentDocument.Id === selectedDocId){
                    this.selectedDocuments.push(element)
                }
            });

            console.log('selectedDocuments :- ',this.selectedDocuments);
        } else {
            console.log('isChecked in ELSE :- ', isChecked);
            this.selectedDocuments = this.selectedDocuments.filter(doc => doc.ContentDocument.Id !== selectedDocId);
            console.log('selectedDocuments :- ',this.selectedDocuments);
        }
    }

    previewHandler(event){
        console.log('dataset id:- ',event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{
                selectedRecordId: event.target.dataset.id
            }
        })
    }

    handleBack(event){
        this.showfolders = true;
        this.showfiles = false;
    }

    handleAddFiles(event){
        if (this.selectedFolderData.length == 0){
            this.template.querySelector('c-toast-component').showToast('error', 'Atleast One Folder is Required to be Selected to add files', 3000);
        } else{
            this.spinnerDataTable = true
            this.showfiles = true;
            this.showfolders = false;
            this.getFilesforselectedRecord()
            console.log('SelectedFolderData :- ', this.selectedFolderData)
        }
    }

    handleRowSelection(event) {
        const selectedRow = event.detail.selectedRows[0];
        const selectedRow2 = event.detail.selectedRows;
        console.log('selectedRow 1:- ', selectedRow)
        console.log('selectedRow 2:- ', selectedRow2)
        this.selectedFolderData = selectedRow2
        console.log('selectedfolderdata :- ',this.selectedFolderData[0]);
    }

    handleNewFolder(event){
        this.showNewFolderPopup = true;
    }

    handleConfirm(event){
        console.log("Handel Confirm")
    }

    handleNameChange(event) {
        this.newFolderName = event.target.value;
    }

    handleDescriptionChange(event) {
        this.newFolderDescription = event.target.value;
    }

    createFolder(){
        this.spinnerDataTable = true
        createPublicFolder({ Fname : this.newFolderName, Fdesc : this.newFolderDescription })
        .then((response) =>{
            console.log('Response for create folder :- ',response);
            this.getFolderDataFromApex()
            this.template.querySelector('c-toast-component').showToast('success', 'New Folder Created Successfully', 3000);
            this.spinnerDataTable = false
        })
        this.showNewFolderPopup = false
    }
}