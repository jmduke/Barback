from fabric.api import local


def angostura():
    local('hugo -s Angostura -d Angostura/public')
    local('s3cmd sync Angostura/public/ s3://getbarback.com/ --acl-public --recursive --add-header=Cache-Control:public,max-age=')
