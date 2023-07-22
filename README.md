# RepoDocHelper
This is a MVP but the purpose it to have a self hosted application where you can specify a public repo that the system will pull and track on an interval to fetch and create a document an LLM can then be called through an API to help you get answers to questions around the project. The system will keep track on the latest commits to make sure you are always up-to-date

Note: This assumes there are documentation `.md` files and that you will need to setup the API keys for OpenAI in order to use the LLM to get the data. Manual deletion of the folder will need to be made.

Starting the application:

  * Run `mix setup` to install and setup dependencies
  * Copy `.envrc-example` and rename to `.envrc`, fill in relevant env variables
  * Start Phoenix endpoint with `source .envrc && mix phx.server` or inside IEx with `iex -S mix phx.server`
