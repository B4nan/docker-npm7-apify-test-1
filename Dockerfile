# First, specify the base Docker image. You can read more about
# the available images at https://sdk.apify.com/docs/guides/docker-images
# You can also use any other image from Docker Hub.
FROM apify/actor-node-puppeteer-chrome:16-8.0.0

# Second, copy just package.json and package-lock.json since those are the only
# files that affect "npm install" in the next step, to speed up the build.
COPY package*.json ./

# Install NPM packages, skip optional and development dependencies to
# keep the image small. Avoid logging too much and print the dependency
# tree for debugging
RUN ls -la ..
RUN whoami \
 && cat package.json \
 && cat /home/myuser/package.json \
 && cat .npmrc \
 && ls -la \
 && printenv \
 && npm --quiet set progress=false \
 && npm install --only=prod --no-optional \
 && echo "Installed NPM packages:" \
 && (npm list || true) \
 && echo "Node.js version:" \
 && node --version \
 && echo "NPM version:" \
 && npm --version || true

# Next, copy the remaining files and directories with the source code.
# Since we do this after NPM install, quick build will be really fast
# for most source file changes.
COPY . ./
RUN ls -la && ls -la ~ && ls -la ~/.npm

# Optionally, specify how to launch the source code of your actor.
# By default, Apify's base Docker images define the CMD instruction
# that runs the Node.js source code using the command specified
# in the "scripts.start" section of the package.json file.
# In short, the instruction looks something like this:
#
# CMD npm start
