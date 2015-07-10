Broker Client
=============

Tasks
-----

- [x] login
	- [x] token persistent in file system
- [x] add apartment
    - [x] images upload to S3
	- [x] basic information form of apartment
	- [x] images synchronization with Ji's internal tool
    - [x] work with Yao's server'
- [x] multiple selection of images
- [x] uploading timeout 
- [ ] memory leaks of datepicker?
- [x] release some memory after pushing to next view?
- [x] list uploading history
    - [x] pull down to refresh
    - [x] pull up to load more
        - [ ] bottom indicator
- [x] fix image rotation caused by removing of tiff info
- [x] add feature of cover image selction
- [x] remove unavailable apartment
- [ ] rewrite some hard code of view -> key
- [x] video
    - [x] video compression
    - [x] video uploading
    - [x] video uploading UI

References
----------

- Image Uploading with `AWSS3 SDK`: https://github.com/aws/aws-sdk-ios
- Multiple images selection with `CTAssetsPickerController`: https://github.com/chiunam/CTAssetsPickerController
- Table view image cache with `SDWebImage`: https://github.com/rs/SDWebImage
- Video preocessing with `SDAVAssetExportSession`: https://github.com/rs/SDAVAssetExportSession

