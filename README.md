# Flutter integration with VGS Show/Collect SDK demo

This examples shows how easily you can integrate VGS Collect/Show Android SDK into your Flutter application and secure sensitive data with us.

<p align="center">
    <img src="screenshots/empty.png" width="150">    
    <img src="screenshots/filled.png" width="150">    
    <img src="screenshots/revealed.png" width="150">     
</p>

## How to run it?

### Requirements

- Installed <a href="https://flutter.dev/docs/get-started/install" target="_blank">Flutter</a>
- Setup <a href="https://flutter.dev/docs/get-started/editor?tab=androidstudio" target="_blank">IDEA</a>
- Organization with <a href="https://www.verygoodsecurity.com/">VGS</a>

> **_NOTE:_**  Please visit Flutter <a href="https://flutter.dev/docs" target="_blank">documentation</a> 
>for more detailed explanation how to setup Flutter and IDEA.

#### Step 1

Go to your <a href="https://dashboard.verygoodsecurity.com/" target="_blank">VGS organization</a> and 
<a href="https://www.verygoodsecurity.io/docs/features/yaml#import-a-single-route" target="_blank">import</a> demo route ``YAML`` config (<a href="./flutter_demo_rout.yaml" target="_blank">Download</a>).

#### Step 2

Clone demo application repository.

`git clone git@github.com:verygoodsecurity/android-sdk-demo.git`

#### Step 3

Setup `"<VAULT_ID>"`.

##### Android

Find `MainActivity.kt` in `android` package and replace `VAULT_ID` constant with your <a href="https://www.verygoodsecurity.com/docs/terminology/nomenclature#vault" target="_blank">vault id</a>.

##### iOS

> **_WARNING:_**  Currently is not implemented, will be available soon.