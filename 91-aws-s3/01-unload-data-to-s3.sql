unload ('select * from venue')
to 's3://mybucket/tickit/unload/venue_' credentials 
'aws_access_key_id=<access-key-id>;aws_secret_access_key=<secret-access-key>'
parallel off
gzip;

