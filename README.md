# Huawei App Gallery Deploy

![820px-Huawei_AppGallery](https://user-images.githubusercontent.com/71822189/116457944-51f2e180-a864-11eb-86b9-520603a9d63a.png)

A modern GitHub Action that uploads your .apk/.aab to Huawei App Gallery with composite action
structure, better error handling, and support for the latest Node.js versions.

This action supports Linux, Windows, and macOS.

## Generate Client Keys

Client Id and Client Key need to be created in the AppGallery console. Sign in to AppGallery Connect
and select:

1. **Users and permissions** → **Api Key** → **Connect API**
2. Set up your project as `N/A`
3. Add the role `Administrator` to it
4. Generate your Client ID and Client Key

## Inputs

| Input            | Description                                                    | Required | Default       |
|------------------|----------------------------------------------------------------|----------|---------------|
| `client-id`      | Client Id generated from Connect API                           | ✅        | -             |
| `client-key`     | Client Key generated from Connect API                          | ✅        | -             |
| `app-id`         | App ID found on App Information in AppGallery Connect          | ✅        | -             |
| `file-extension` | File name extension (apk/rpk/pdf/jpg/jpeg/png/bmp/mp4/mov/aab) | ✅        | `apk`         |
| `file-path`      | Path to the file to upload                                     | ✅        | -             |
| `file-name`      | Desired file name shown in AppGallery Connect                  | ❌        | `app-release` |
| `submit`         | Whether to submit automatically after upload                   | ❌        | `false`       |
| `debug`          | Enable verbose log output for troubleshooting                  | ❌        | `false`       |

## Outputs

| Output                   | Description                                 |
|--------------------------|---------------------------------------------|
| `appgallery_console_url` | Link to the AppGallery console for your app |
| `upload_status`          | Upload status (`success` or `failed`)       |

## Sample Usage

### Basic Usage

```yaml
name: Build and Deploy to AppGallery

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        
    - name: Build APK
      run: ./gradlew assembleRelease
      
    - name: Huawei App Gallery Deploy
      id: appgallery
      uses: emertozd/huawei-app-gallery-deploy-action@v1
      with:
        client-id: ${{ secrets.HUAWEI_CLIENT_ID }}
        client-key: ${{ secrets.HUAWEI_CLIENT_KEY }}
        app-id: ${{ secrets.HUAWEI_APP_ID }}
        file-extension: "apk"
        file-path: "apk/release/app-release.apk"
        file-name: "MyAppName-1.0.0"
        submit: true
        debug: false
        
    - name: Print deployment info
      run: |
        echo " Upload Status: ${{ steps.appgallery.outputs.upload_status }}"
        echo " AppGallery Console: ${{ steps.appgallery.outputs.appgallery_console_url }}"
```

### Advanced Usage with Conditional Submission

```yaml
- name: Huawei App Gallery Deploy
  id: appgallery
  uses: emertozd/huawei-app-gallery-deploy-action@v1
  with:
    client-id: ${{ secrets.HUAWEI_CLIENT_ID }}
    client-key: ${{ secrets.HUAWEI_CLIENT_KEY }}
    app-id: ${{ secrets.HUAWEI_APP_ID }}
    file-extension: "aab"
    file-path: "app/build/outputs/bundle/release/app-release.aab"
    file-name: "MyApp-${{ github.ref_name }}-${{ github.sha }}"
    submit: ${{ github.ref == 'refs/heads/main' }}
    debug: ${{ secrets.ACTIONS_STEP_DEBUG == 'true' }}
```

## Secrets Setup

Add these secrets to your GitHub repository:

1. **HUAWEI_CLIENT_ID**: Your AppGallery Connect API Client ID
2. **HUAWEI_CLIENT_KEY**: Your AppGallery Connect API Client Key
3. **HUAWEI_APP_ID**: Your App ID from AppGallery Connect

## Migration from v1

If you're upgrading from v1, the main changes are:

1. Now uses composite action with Node.js 20
2. Better error handling and validation
3. Modern dependency updates for security
4. Additional debug output support
5. Action outputs for status and URLs

## Troubleshooting

### Enable Debug Mode

Set `debug: true` in your action configuration to see verbose logs:

```yaml
- name: Huawei App Gallery Deploy
  uses: emertozd/huawei-app-gallery-deploy-action@v1
  with:
    # ... other inputs
    debug: true
```

### Common Issues

1. **"File not found" error**: Ensure the file path is correct and the file exists in your workflow
2. **"Client credentials invalid"**: Double-check your Client ID and Client Key in AppGallery
   Connect
3. **"Upload failed"**: Check that your file size is within AppGallery limits and the file format is
   supported

## References

- [Huawei AppGallery Connect API Documentation](https://developer.huawei.com/consumer/en/doc/development/AppGallery-connect-Guides/agcapi-getstarted-0000001111845114)
- [App File Upload API](https://developer.huawei.com/consumer/en/doc/development/AppGallery-connect-Guides/agcapi-upload_appfile-0000001158365309)

## Contributing

This action is maintained by E.Mert Özdemir to fix issues and provide modern GitHub Action features.

For issues and contributions, visit: https://github.com/emertozd/huawei-app-gallery-deploy-action

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
