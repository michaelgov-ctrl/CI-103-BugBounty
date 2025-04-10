
$body = [pscustomobject]{
    ProgramIds = @("cb490e4a-d68b-402c-b68a-aed2d6a04835")
    CourseOfferingIds = $null
}

#Invoke-RestMethod -Uri https://reccenter.drexel.edu/api/Price/GetPrices -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"

Invoke-RestMethod -uri reccenter.drexel.edu/account/getloginoptions


<#
registration process
    POST
    /ProgramRegistration/InitiateGroupRegistrationForInstances

    programId=5f25a385-fb37-4ce2-8ddd-73508b5c67ab&instances%5B0%5D%5BProgramId%5D=5f25a385-fb37-4ce2-8ddd-73508b5c67ab&instances%5B0%5D%5BProgramInstanceId%5D=00000000-0000-0000-0000-000000000000&instances%5B0%5D%5BAppointmentId%5D=afa2dcff-890c-4e68-8d30-e3724c7e627d&instances%5B0%5D%5BStartTime%5D=4%2F11%2F2025+6%3A00%3A00+PM&instances%5B0%5D%5BEndTime%5D=4%2F11%2F2025+7%3A00%3A00+PM&t=&v=0&isFamilyRegistration=false&sourceTypeCV=&clickTrackId=

    GET
    /registration/2f67010e-4d2a-4c54-bc35-2046f95dc57b 

    GET
    /Content/innosoftProgramGroupRegistrationCSS?v=yuCMXYONpOwVJFCCt02P3GkUHPBkJE7EeUmw-giWCa81

    POST
    /ProgramRegistration/UpdateGroupRegistrationStatus

    groupRegistrationId=2f67010e-4d2a-4c54-bc35-2046f95dc57b&statusCV=00000000-0000-0000-0000-000000004534

    POST
    /ProgramRegistration/UpdateGroupRegistrationStatus

    groupRegistrationId=2f67010e-4d2a-4c54-bc35-2046f95dc57b&statusCV=00000000-0000-0000-0000-000000004535

    GET
    /ProgramRegistration/GetGroupRegistrationStepper?groupRegistrationId=2f67010e-4d2a-4c54-bc35-2046f95dc57b 

    GET
    /ProgramRegistration/GetGroupRegistrationSteps?groupRegistrationId=2f67010e-4d2a-4c54-bc35-2046f95dc57b

    GET
    /ProgramRegistration/GetActiveGroupRegistrationStep?groupRegistrationId=2f67010e-4d2a-4c54-bc35-2046f95dc57b&groupRegistrationStepId=00000000-0000-0000-0000-000000004537 

    GET
    /ProgramRegistration/GetPaymentOptionsForRegistrant?partyId=bf283d89-aa26-4c5d-ac64-1c5cd4080ed9&productId=5f25a385-fb37-4ce2-8ddd-73508b5c67ab&offeringInstanceId=b2354c29-dc8e-4c76-a18f-c8d3e3c0591f%20

    POST
    /ProgramRegistration/SelectPaymentOptionForProgramRegistration 

    registrationId=dc346fde-2e2f-415e-a133-082b09405f7d&priceId=00000000-0000-0000-0000-000000000000

    POST
    /ProgramRegistration/CompleteGroupRegistrationStep

    groupRegistrationId=2f67010e-4d2a-4c54-bc35-2046f95dc57b&groupRegistrationStepId=00000000-0000-0000-0000-000000004537

    GET
    /ProgramRegistration/GetGroupRegistrationSteps?groupRegistrationId=2f67010e-4d2a-4c54-bc35-2046f95dc57b

    GET
    /Cart/Index

    POST
    /Checkout/Checkout 

    GET
    /ProcessorResponse/ZeroDollarReceipt
#>