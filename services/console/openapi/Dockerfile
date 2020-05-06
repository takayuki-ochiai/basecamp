FROM stoplight/prism:3.3.3 as base
COPY . .
CMD ["sleep", "infinity"]

FROM base as tutorial
CMD ["mock", "-h", "0.0.0.0", "-d", "./tutorial/training.yaml"]

FROM base as v1mock
CMD ["mock", "-h", "0.0.0.0", "-d", "./v1/schema.yaml"]
