# RepoDocHelper
This is a self hosted application where you can specify a public repo that the system will pull and track on an interval to fetch and create a document an LLM can then be called through an API to help you get answers to questions around the project. The system will keep track on the latest commits to make sure you are always up-to-date by having the user execute an endpoint `/api/initialize` to pull and create the dataset needed to query against with OpenAI.

Note: This assumes there are documentation `.md` files and that you will need to setup the API keys for OpenAI in order to use the LLM to get the data. Manual deletion of the folder will need to be made.

Starting the application:

  * Run `mix setup` to install and setup dependencies
  * Copy `.envrc-example` and rename to `.envrc`, fill in relevant env variables
  * Start Phoenix endpoint with `source .envrc && mix phx.server` or inside IEx with `iex -S mix phx.server`

## Dependencies

- Python (atleast 3.9): You will need to install python as the system will run commands against the python from shell scripts. 
- Langchain (python) - The library for that will consume files
- Chroma (python) - We use this as a Vector database store with the data we will parse from OpenAI (document files)
- Erlang/Elixir - The system will mainly run on this and setup can be done through here: https://elixir-lang.org/install.html

## How it works
Once the application is running (note the port that is setup in the your `.envrc` file, it defaults to `4000`), You will have endpoints accessible to you.


### `[POST] /api/initialize`
---
**What:** This will pull down the repo you have setup in the `.envrc` and create a `/_DOCUMENTS` folder, where the system will then walk through and find all the `.md` files that will then need to be flattened into one document for `langchain` and their document text loader to query against

**Example Response:**
```
{
    "code": 200,
    "result": "The data is being initialized...",
    "success": true
}
```

### `[POST] /api/query`
---
Will use the data of the file that was generated through the initialize and then query against it using the OpenAI token set with the `.envrc` and then querying against the document for an answer.

**Example Request:**
```
{
    "ask": "How do I get my access tokens?" 
}
```

**Example Response:**
```
{
    "code": 200,
    "result": "You can get an access token by making a request to the authentication endpoint with your client credentials. The request body must have a field grant_type with value client_credentials. It will return a bearer token that you can use in all subsequent API requests. The Postman collection comes with an \"Authentication -> 200 - OK\" request that you can can run with your account credentials to try this out for yourself.",
    "success": true
}
```

### `[GET] /api/status`
---
This will check the existence of the `_MODEL_DATA` directory and the text document that is generated, `model_data.txt`. This will need to exist and you will get back a message around knowing if the model exists or if you need to run the initialize request before any query can take place. This is needed because this can be used against any public repo and its `.md` files and there is no file size limit which it would need to download first anyway before we move on to creating the model text file to query against.

**Example Response:**
```
{
    "code": 200,
    "result": "Dataset exists, to query run a /query (POST)",
    "success": true
}
```

We also have errors if the directories and files do not exist with error codes `4xx` in those case as a response and letting you know that you will need to call the initialize

## Notes
- This is **NOT** production ready!
- Would be better to have a Vector database store hosted to query against
- Custom LLM that is smaller and local along with fine-tuned would be better suited in the long run
- Ideally would rather have a GitHub action that could call a script that would do the `initialize` part so the system wont need to pull data and try workout the relevant files to create the document
- Make smaller files as this can result in one large file, slow response times from the LLM needing
- Executing Pyhton through Elixir relying on system commands is not ideal, separate process execution of python files would be better
- Packing and hosting as a Docker container might make this easier to use down the line for others to self host
- Logging and error gaurds - this can be cleaned up and more can be added
- Tests would help at the end of all the cleanup and optimization to make sure the code works as expected
