'use strict'

##################################################
# init
##################################################
express     = require 'express'
image       = express.Router()
tms         = require '../helper/tms'
acl         = require '../helper/acl'
multer      = require 'multer'
upload      = multer {dest: 'upload/'}
sharp       = require 'sharp'
promise     = require 'bluebird'
UPLOAD_PATH = __dirname + '/../upload/'


##################################################
# upload AWS S3
##################################################
aws     = require 'aws-sdk'
fs      = require 'fs'
aws.config.update {accessKeyId:IAM.ACCESS, secretAccessKey:IAM.SECRET, region: IAM.REGION}
bucket = new aws.S3({params:{Bucket:IAM.BUCKET, ACL:'public-read', ContentType:'image/jpeg'}})
uploadToS3 = (filename, cb)->
  params =
    Key  : filename
    Body : fs.createReadStream(UPLOAD_PATH + filename)
  bucket.upload(params).send(cb)


######################################################################
# REST API
######################################################################
image.post '/', tms.verifyToken
image.post '/', upload.any 'image'
image.post '/', (req, res)->
  unless req.files        then return res.status(400).json {data: RCODE.IMAGE_REQUIRED}
  if req.files.length < 1 then return res.status(400).json {data: RCODE.IMAGE_REQUIRED}

  promise.map req.files, (file)->
    # resize
    sharp(UPLOAD_PATH + file.filename)
    .resize(RESIZE.W, RESIZE.H).max().jpeg()
    .toFile(UPLOAD_PATH + file.filename + RESIZE.EXT)
    .then ->
      return new promise (resolve, reject)->
        uploadToS3 file.filename + RESIZE.EXT, (err, data)->
          if err then reject(err)
          fs.unlink UPLOAD_PATH + file.filename + RESIZE.EXT , (err)-> if err then reject(err)
          resolve()
    # resize thumbnail
    .then ->
      sharp(UPLOAD_PATH + file.filename)
      .resize(RESIZE.THUMB_W, RESIZE.THUMB_H)
      .toFile(UPLOAD_PATH + file.filename + RESIZE.THUMB_EXT)
      .then ->
        return new promise (resolve, reject)->
          uploadToS3 file.filename + RESIZE.THUMB_EXT, (err, data)->
            if err then reject(err)
            fs.unlink UPLOAD_PATH + file.filename + RESIZE.THUMB_EXT , (err)-> if err then reject(err)
            fs.unlink UPLOAD_PATH + file.filename, (err)-> if err then reject(err)
            resolve()

  .then ->
    if APP.S3_PROXY
      url = APP.URL + '/image/'
    else
      url = 'https://' + IAM.BUCKET + '.s3-' + IAM.REGION + '.amazonaws.com/'

    for file in req.files
      file.url      = url + file.filename + RESIZE.EXT
      file.urlThumb = url + file.filename + RESIZE.THUMB_EXT

      return res.json {data: req.files}

  .catch (err)-> return res.status(500).json {data: RCODE.SERVER_ERROR}

image.get '/:filename', (req, res)->
  unless req.params.filename then return res.status(400).json {data: RCODE.FILENAME_REQUIRED}

  if APP.S3_PROXY
    res.type('jpeg')
    return bucket.getObject({Key:req.params.filename}).createReadStream().pipe(res)
  else
    url = 'https://' + IAM.BUCKET + '.s3-' + IAM.REGION + '.amazonaws.com/' + req.params.filename
    return res.redirect(url)

module.exports = image