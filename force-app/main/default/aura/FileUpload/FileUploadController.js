({  
    
    handleUploadFinished : function (cmp, event){  
        
        var uploadedFiles = event.getParam("files");  
        var action = cmp.get("c.getClient");  
        var accountId = cmp.get("v.recordId");
        action.setParams({ "accId" : accountId });  
        action.setCallback(this, function(response) {  
            var state = response.getState();  
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'File Uploaded to Google Drive Successfully!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }  
        });  
        $A.enqueueAction(action);  
        // alert("Files uploaded Client : " + uploadedFiles.length);  
        
    }  
    
})