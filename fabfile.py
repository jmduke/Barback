import os

from fabric.api import local, lcd
import gzip

def wimshurst():
    with lcd('Angostura'):
        local('python3 ./wimshurst.py')

def gzip_directory(directory):
    for root, dirs, files in os.walk(directory):
        for f in files:
            if os.path.splitext(f)[1] in ['.html', '.css', '.js']:
                current_path = os.path.join(root, f)
                with open(current_path, 'rb') as f_in:
                    with gzip.open(current_path + '.gz', 'wb') as f_out:
                        f_out.writelines(f_in)
                os.rename(current_path + '.gz', current_path)

def angostura(dry_run=False):
    site_directory = 'Angostura'
    generated_site_directory = 'Angostura/public/'

    local('rm -rf {}*'.format(generated_site_directory))
    local('~/go/bin/hugo -s {} -d public --theme=barback'.format(site_directory, generated_site_directory))

    # Test site.
    wimshurst()

    gzip_directory(generated_site_directory)

    # Upload non-compressed assets.
    uncompressed_upload_command = "s3cmd sync {} s3://getbarback.com".format(generated_site_directory)

    # Exclude compressed assets.
    uncompressed_upload_command += " --exclude '*.html' --exclude '*.js' --exclude '*.css'"

    # Make it viewable.
    uncompressed_upload_command += ' -P'

    if dry_run:
        # Make it a dry run.
        uncompressed_upload_command += ' --dry-run'

    # Make it recursive.
    uncompressed_upload_command += ' --recursive'

    # Cache it for five minutes.
    uncompressed_upload_command += ' --add-header=Cache-Control:public,max-age=300'

    local(uncompressed_upload_command)

    compressed_upload_command = "s3cmd sync {} s3://getbarback.com".format(generated_site_directory)

    # Include compressed assets.
    compressed_upload_command += " --exclude '*.*' --include '*.html' --include '*.js' --include '*.css'"

    # Make it viewable.
    compressed_upload_command += ' -P'

    if dry_run:
        # Make it a dry run.
        compressed_upload_command += ' --dry-run'

    # Make it recursive.
    compressed_upload_command += ' --recursive'

    # Cache it for five minutes.
    compressed_upload_command += ' --add-header=Cache-Control:public,max-age=2592000'

    # Mark it as compressed.
    compressed_upload_command += ' --add-header="Content-Encoding: gzip"'

    local(compressed_upload_command)
