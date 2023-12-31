# Chatting System

A real-time chatting system built with Rails 7, MySQL, ElasticSearch, and Sidekiq.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Tests](#Tests)
- [Usage](#usage)
- [Demo Video](#DemoVideo)
- [API Documentations](#APIDocumentations)


## Introduction

This project is a chatting system developed using the Ruby on Rails framework. It leverages MySQL as the primary database, ElasticSearch for efficient message searching, and Sidekiq for background job processing.

## Features

- **MySQL Database:** Store and manage user data, chat messages, and system information.
- **ElasticSearch Integration:** Efficiently search messages using ElasticSearch for a seamless user experience.
- **Background Job Processing:** Sidekiq handles background jobs, ensuring optimal system performance.
- **Scalable:** The architecture is designed to scale with the growing user base.

## Prerequisites

Make sure you have the following installed on your system:

- Ruby 3.1
- Rails 7
- MySQL
- ElasticSearch
- Sidekiq

## Getting Started

### Installation

1. Clone the repository

2. Install dependencies:

    ```bash
    cd chatting-system
    bundle install
    ```

### Configuration

1. Configure the database:

    Update `config/database.yml` with your MySQL credentials.

2. Configure ElasticSearch:

    Ensure ElasticSearch is running, and update `config/elasticsearch.yml` if needed.

3. Start the application:

    ```bash
    rails db:create db:migrate
    rails s
    ```

Visit `http://localhost:3000` in your browser.

### Unit Tests:

    Rspec
 By Running this command your tests will run.
## Usage

1. Create an Application.
2. Start chats per Application.
3. Utilize search functionalities powered by ElasticSearch.
4. Background jobs are handled by Sidekiq for enhanced performance.

### Demo Video
Visit [Demo](https://www.veed.io/view/a19f6ca4-6749-43c5-8727-bb1f8689caea?panel=share) in ypur browser.

## API Documentations

Visit [API_DOCS](https://documenter.getpostman.com/view/31540918/2s9YkjANf1) in your browser. 
