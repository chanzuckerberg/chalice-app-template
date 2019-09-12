import os, logging

from chalice import Chalice

log_level = logging.getLevelName(os.environ.get("LOG_LEVEL", "INFO"))
logging.basicConfig(level=log_level)
logging.getLogger().setLevel(log_level)

app = Chalice(app_name='chalice-app-template')
app.debug = True if log_level == logging.DEBUG else False
for l in "botocore.vendored.requests.packages.urllib3.connectionpool", "requests.packages.urllib3.connectionpool":
    logging.getLogger(l).setLevel(max(log_level, logging.WARNING))

logger = logging.getLogger(__name__)

@app.route('/')
def index():
    app.log.debug("This is a debug logging test with the app logger")
    app.log.error("This is an error logging test with the app logger")
    logger.debug("This is a debug logging test with the module logger")
    logger.error("This is an error logging test with the module logger")
    return {'hello': 'world'}


# The view function above will return {"hello": "world"}
# whenever you make an HTTP GET request to '/'.
#
# Here are a few more examples:
#
# @app.route('/hello/{name}')
# def hello_name(name):
#    # '/hello/james' -> {"hello": "james"}
#    return {'hello': name}
#
# @app.route('/users', methods=['POST'])
# def create_user():
#     # This is the JSON body the user sent in their POST request.
#     user_as_json = app.current_request.json_body
#     # We'll echo the json body back to the user in a 'user' key.
#     return {'user': user_as_json}
#
# See https://github.com/aws/chalice for more examples.
#
