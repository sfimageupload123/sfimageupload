({
    onHandleClick : function(component, event, helper) {
        
        let dateVal = component.find ('datevalue').get ('v.value');
        
        if (!dateVal || dateVal === undefined || dateVal === null) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please Enter a Date',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }else{
            component.set("v.showLoadingSpinner", true);
            let self = this;
            var contentIdsPromise = this.getContentDocumentIdsMethod(component, event);            
            Promise.all ([contentIdsPromise
                         ]).then ( 
                $A.getCallback (function (results) {
                    component.set("v.showLoadingSpinner", false);
                    if (results && results !== null && results !== undefined) {
                        if(results[0] !== null){

                            var originPath = '/sfc/servlet.shepherd/document/download/'; // Need to be made dynamic
                            alert(originPath);
                            var contentIdString='';
                            for(var i = 0;i<results[0].length;i++){
                                contentIdString= contentIdString + results[0][i] + '/';
                            }
                            var finalPath = originPath + contentIdString + '?operationContext=S1';
                            window.open(finalPath,'_new');
                            
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Info',
                                message: 'No Files above 8MB Found for mentioned Date.',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'info',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }
                    }       
                }), 
                $A.getCallback(function(error) {
                    component.set("v.showLoadingSpinner", false);
                    console.log ('Error :' + error);
                })
            );
            
            
        }
    },
    
    getContentDocumentIdsMethod : function (component, event) {
        let self = this;
        return new Promise ($A.getCallback(function (resolve, reject) {
            let params = {
                'dateSelected' : component.get ('v.dateVal'),
                
            };
            let action = component.get ('c.getContentDocumentIdsApex');
            action.setParams (params)
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === 'SUCCESS') {
                    resolve(response.getReturnValue());
                } else if (state === "INCOMPLETE") {
                    //todo
                    reject('Incomplete');
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    reject(response.getError());
                }
            });
            $A.enqueueAction(action);
        }));
    },
})