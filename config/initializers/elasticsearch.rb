# config/initializers/elasticsearch.rb

Elasticsearch::Model.client = Elasticsearch::Client.new(
    cloud_id: 'My_deployment:dXMtY2VudHJhbDEuZ2NwLmNsb3VkLmVzLmlvOjQ0MyQxM2JlZGM0OWU5ODc0ZDQ0YjIwOTg0OTQ1MDA3Y2JiYyRlMmNkMTJkMjIzMDg0ZWFhOGNhNTUxNjNjMDBmZDU5ZA==',
    user: 'elastic',
    password: 'UAIQfvAP60kscyx8MEfyI46C',
)



  