import base64
import uuid

from flask import Flask, Response, request

import os

app = Flask(__name__)

model_path = "/app/stablediffusion/models/ldm/stable-diffusion-2-v1/model.ckpt"


@app.route('/healthcheck')
def hello_world():
    return Response(status=200)


@app.route('/', methods=['POST'])
def generate():
    req = request.json()
    output_dir = "/app/outputs/txt2img/{}".format(uuid.uuid4())
    command = "python /app/stablediffusion/scripts/txt2img.py"
    command += " --prompt {}".format(req['prompt'])
    command += " --ckpt {}".format(model_path)
    command += " --output {}".format(output_dir)
    command += " --steps {}".format(req['steps'])
    command += " --seed {}".format(req['seed'])
    command += " --H {}".format(req['height'])
    command += " --W {}".format(req['width'])

    if req['scale'] is not None:
        command += " --scale {}".format(req['scale'])

    if req['n_iter'] is not None:
        command += " --n_iter {}".format(req['iterations'])

    if req['n_samples'] is not None:
        command += " --n_samples {}".format(req['samples'])

    os.system(command)

    grid_count = len(os.listdir(output_dir)) - 1
    with open(f"{output_dir}/grid-{grid_count:04}.png", 'rb') as image_file:
        base64_encoded_image = base64.b64encode(image_file.read())

    os.system(f"rm -r {output_dir}")

    return Response(base64_encoded_image, status=200)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)
