param location string
param galleryname string

resource aig 'Microsoft.Compute/galleries@2022-03-03' = {
  location: location
  name: galleryname
  properties: {
    description: 'MonStar gallery'
  }
}
