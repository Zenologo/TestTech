# About This Repository

To complete this technical test, I have created the following Apex classes:

- A trigger [<em>AccountCanceled</em>](https://github.com/Zenologo/TestTech/blob/main/force-app/main/default/triggers/AccountCanceled.trigger) that triggers manipulations on condition.

- A class [<em>AccountHandler</em>](https://github.com/Zenologo/TestTech/blob/main/force-app/main/default/classes/AccountHandler.cls) that contains methods to implement the functionalities.

- A class test [<em>AccountHandlerTest</em>](https://github.com/Zenologo/TestTech/blob/main/force-app/main/default/classes/AccountHandlerTest.cls) that simulates real cases and verifies the results.

- A class Mock [<em>AccountHandlerMock</em>](https://github.com/Zenologo/TestTech/blob/main/force-app/main/default/classes/AccountHandlerMock.cls) that simulates and tests the Callout method.

## Configuration Of Named Credential

In order to run the code securely and simplify our deployment in Salesforce, we can use <em><strong>Named Credential</strong></em>. 

In this case, I have created: 

- a Named Credentrial <em>AWS_SF_Contact</em> that saves the endpoint.

- an External Credentail <em>AWS</em> that set up all headers and authorization.

There is un example about settings  Named Credentrial in my case: 

- Named Credential
  
![Capture d'écran 2024-10-30 094529](https://github.com/user-attachments/assets/d9491b4a-d635-4ee0-8f2a-f9582ad5f1a3)




- External Crediential
  
![Capture d'écran 2024-10-30 094359](https://github.com/user-attachments/assets/634dff13-8f60-46b6-8bcc-2103a3533b3f)





## Read All About It

- [Salesforce Named Credential](https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm&type=5https://developer.salesforce.com/tools/vscode/)
- [CreateCreate Named Credentials and External Credentials](https://help.salesforce.com/s/articleView?id=sf.nc_named_creds_and_ext_creds.htm&type=5)
