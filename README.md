![Ruby](https://github.com/SampsonCrowley/api_view_versions/workflows/Ruby/badge.svg?branch=master)
[![Code Climate](https://codeclimate.com/github/SampsonCrowley/api_view_versions.png)](https://codeclimate.com/github/SampsonCrowley/api_view_versions)
[![Coverage Status](https://coveralls.io/repos/SampsonCrowley/api_view_versions/badge.png?branch=master)](https://coveralls.io/r/SampsonCrowley/api_view_versions)
[![Gem Version](https://badge.fury.io/rb/api_view_versions.png)](http://badge.fury.io/rb/api_view_versions)

forked from [VersionCake](https://github.com/bwillis/versioncake)

API View Versions is an Opinionated and Slimmed down Fork of [Version Cake](https://github.com/bwillis/versioncake)

- Easily version any view with their API version:

```ruby
app/views/posts/
 - index.xml.v1.builder
 - index.xml.v3.builder
 - index.json.v1.jbuilder
 - index.json.v4.jbuilder
```
- Gracefully degrade requests to the latest supported version
- Dry your controller logic with exposed helpers

Check out https://github.com/bwillis/350-rest-api-versioning for a comparison of traditional versioning approaches and a versioncake implementation.

## Install

```
gem install api_view_versions
rails g api_view_versions:install
```

### Requirements

| Version             | Rails >4.2 Support? | Rails >5 Support? | Rails >5.2 Support? | Rails 6 Support? | [Rails API](https://github.com/rails-api/rails-api) 0.2 Support? |
| -------------------:|:-------------------:| -----------------:| -------------------:| ----------------:| -------------------------:|
| [1.0](CHANGELOG.md) | Yes                 | Yes               | Yes                 | Yes              | Yes                       |


### Configuration Options

The configuration options are:

| New Name                 |
| ------------------------ |
| config.resources         |
| config.vendor_string     |
| config.missing_version   |
| config.mime_types        |
| config.performance_mode  |

## Example

In this simple example we will outline the code that is introduced to support a change in a version.

### config/application.rb
```ruby
ApiViewVersions.setup do |config|
  config.resources do |r|
    r.resource %r{.*}, [], [], (1..4)
  end
  # ACCEPT application/vnd.mycompany+json; version=1
  config.version_key = "mycompany"
  config.missing_version = 4
end
```

Often times with APIs, depending upon the version, different logic needs to be applied. With the following controller code, the initial value of @posts includes all Post entries.
But if the requested API version is three or greater, we're going to eagerly load the associated comments as well.

Being able to control the logic based on the api version allow you to ensure forwards and backwards compatibility for future changes.

### PostsController
```ruby
class PostsController < ApplicationController
  def index
    # shared code for all versions
    @posts = Post.scoped

    # version 3 or greated supports embedding post comments
    if request_version >= 3
      @posts = @posts.includes(:comments)
    end
  end
end
```

See the view samples below. The basic top level posts are referenced in views/posts/index.json.v1.jbuilder.
But for views/posts/index.json.v4.jbuilder, we utilize the additional related comments.

### Views

Notice the version numbers are denoted by the "v{version number}" extension within the file name.

#### views/posts/index.json.v1.jbuilder
```ruby
json.array!(@posts) do |post|
  json.(post, :id, :title)
end
```

#### views/posts/index.json.v4.jbuilder
```ruby
json.array!(@posts) do |post|
  json.(post, :id, :title)
  json.comments post.comments, :id, :text
end
```

### Sample Output

When a version is specified for which a view doesn't exist, the request degrades and renders the next lowest version number to ensure the API's backwards compatibility.  In the following case, since views/posts/index.json.v3.jbuilder doesn't exist, and neither does views/posts/index.json.v2.jbuilde, views/posts/index.json.v1.jbuilder is rendered.

(Side note: even though the comments are included for v3 in the controller, the view does not use them here, since only v4 has a view that supports them)

#### http://localhost:3000/posts.json
#### ACCEPT application/vnd.mycompany+json; version=3
```javascript
[
  {
    id: 1
    title: "Version Cake v0.1.0 Released!"
    name: "Ben"
    updated_at: "2012-09-17T16:23:45Z"
  },
  {
    id: 2
    title: "Version Cake v0.2.0 Released!"
    name: "Jim"
    updated_at: "2012-09-17T16:23:32Z"
  }
]
```

For a given request, if we specify the version number, and that version of the view exists, that version specific view version will be rendered.  In the below case, views/posts/index.json.v1.jbuilder is rendered.

#### http://localhost:3000/posts.json
#### ACCEPT application/vnd.mycompany+json; version=1
```javascript
[
  {
    id: 1
    title: "Version Cake v0.1.0 Released!"
    name: "Ben"
    updated_at: "2012-09-17T16:23:45Z"
  },
  {
    id: 2
    title: "Version Cake v0.2.0 Released!"
    name: "Jim"
    updated_at: "2012-09-17T16:23:32Z"
  }
]
```


When no version is specified, the configured `missing_version` will be used to render a view.  In this case, views/posts/index.json.v4.jbuilder.

#### http://localhost:3000/posts.json
#### ACCEPT application/json
```javascript
[
  {
    id: 1
    title: "Version Cake v0.1.0 Released!"
    name: "Ben"
    updated_at: "2012-09-17T16:23:45Z"
    comments: [
      {
        id: 1
        text: "Woah interesting approach on versioning"
      }
    ]
  },
  {
     id: 2
     title: "Version Cake v0.2.0 Released!"
     name: "Jim"
     updated_at: "2012-09-17T16:23:32Z"
     comments: [
      {
        id: 4
        text: "These new features are greeeeat!"
      }
    ]
  }
]
```

## How to use

### Configuration
The configuration lives in `config/initializers/api_view_versions.rb`.

#### Versioned Resources
Each individual resource uri can be identified by a regular expression. For each one it can be customized to have obsolete, deprecated, supported versions.

```ruby
  config.resources do |r|
    # r.resource uri_regex, obsolete, deprecated, supported

    # version 2 and 3 are still supported on users resource
    r.resource %r{/users}, [1], [2,3], [4]

    # all other resources only allow v4
    r.resource %r{.*}, [1,2,3], [], [4]
  end
```

#### Extraction Strategy

Unlike [Version Cake](https://github.com/bwillis/versioncake), this gem only implements the HTTP Accept header strategy.

Clients send an HTTP Accept header with `application/vnd.{{VERSION_KEY}}+json; version={{VERSION_NUMBER}}`

[why do this?](http://blog.steveklabnik.com/posts/2011-07-03-nobody-understands-rest-or-http#i_want_my_api_to_be_versioned)

This is also the strategy taken by the minimalist gem [api-versions](https://github.com/EDMC/api-versions), which was my
inspiration for minimizing the awesome Version Cake gem.

#### Default Version

When no version is supplied by a client, the version rendered will be the latest version by default. If you want to override this to another version, set the following property:
```ruby
config.missing_version = 4
```

#### Version String

The extraction strategies depends on you to set the `version_key` config param:

```ruby
config.version_key = "special_version_parameter_name"
```

will result in and `ACCEPT` header format of:

`application/vnd.special_version_parameter_name+json; version=1`

#### Version String
If you do not wish to use the magic mapping of the version number to templates it can be disabled:
```ruby
config.rails_view_versioning = false
```

#### Response Version

If a client requests a specific version (or does not) and a version applies to the resource you can configure it to be in the response. Use the following configuration:
```ruby
config.api_view_versions.response_strategy = [:http_content_type, :http_header]
```

### Version your views

When a client makes a request to your controller the latest version of the view will be rendered. The latest version is determined by naming the template or partial with a version number that you configured to support.

```
- app/views/posts
    - index.html.erb
    - edit.html.erb
    - show.html.erb
    - show.json.jbuilder
    - show.json.v1.jbuilder
    - show.json.v2.jbuilder
    - new.html.erb
    - _form.html.erb
```

If you start supporting a newer version, v3 for instance, you do not have to copy posts/show.v2 to posts/show.v3. By default, the request for v3 or higher will gracefully degrade to the view that is the newest, supported version, in this case posts/show.v2.

### Controller

You don't need to do anything special in your controller, but if you find that you want to perform some tasks for a specific version you can use `request_version` and `version_context.resource.latest_version`.
```ruby
def index
  # shared code for all versions
  @posts = Post.scoped

  # version 3 or greated supports embedding post comments
  if request_version >= 3
    @posts = @posts.includes(:comments)
  end
end
```

### Client requests

When a client makes a request it will automatically receive the latest supported version of the view. The client can also request for a specific version by one of the strategies configured by ``view_version_extraction_strategy``.

### Raised exceptions

These are the types of exceptions ApiViewVersions will raise:

|Exception type|Description|
|--------------|-----------|
|ApiViewVersions::UnsupportedVersionError| The version is invalid, too high or too low for the resource.|
|ApiViewVersions::ObsoleteVersionError|The version is obsolete for the resource.|
|ApiViewVersions::MissingVersionError|If no `config.missing_version` is specified, this will be raised when no version is in the request.|

### Handling Exceptions

Handling exceptions can simply be done by using Rails `rescue_from` to return app specific messages to the client.

```ruby
class ApplicationController < ActionController::Base

  ...

  rescue_from ApiViewVersions::UnsupportedVersionError, :with => :render_unsupported_version

  private

  def render_unsupported_version
    headers['API-Version-Supported'] = 'false'
    respond_to do |format|
      format.json { render json: {message: "You requested an unsupported version (#{request_version})"}, status: :unprocessable_entity }
    end
  end

  ...

end

```

## How to test

Testing can be painful but here are some easy ways to test different versions of your api using version cake.

### Test configuration

Allowing more extraction strategies during testing can be helpful when needing to override the version.
```ruby
# config/environments/test.rb
config.extraction_strategy = [:query_parameter, :request_parameter, :http_header, :http_accept_parameter]
```

### Testing a specific version

One way to test a specific version for would be to stub the requested version in the before block:
```ruby
before do
  @controller.stubs(:request_version).returns(3)
end
```

You can also test a specific version through a specific strategy such query_parameter or request_parameter strategies (configured in test environment) like so:
```ruby
# test/integration/renders_integration_test.rb#L47
test "render version 1 of the partial based on the parameter _api_version" do
  get renders_path("api_version" => "1")
  assert_equal "index.html.v1.erb", @response.body
end
```

### Testing all supported versions

You can iterate over all of the supported version numbers by accessing the ```ApiViewVersions.config.versioned_resources.first.available_versions```.

```ruby
ApiViewVersions.config.versioned_resources.first.available_versions.each do |supported_version|
  before do
    @controller.stubs(:request_version).returns(supported_version)
  end

  test "all versions render the correct template" do
    get :index
    assert_equal @response.body, "index.html.v1.erb"
  end
end
```

# Thanks!

Thanks to the original contributors and thank list from VersionCake at the time of forking:

* [Ben Willis](https://github.com/bwillis) (coauthor of VersionCake)
* [Jim Jones](https://github.com/aantix) (coauthor of VersionCake)
* [Manilla](https://github.com/manilla)
* [Alicia](https://github.com/alicial)
* [Rohit](https://github.com/rg)
* [Sevag](https://github.com/sevagf)
* [Billy](https://github.com/bcatherall)
* [Jérémie Meyer de Ville](https://github.com/jeremiemv)
* [Michael Elfassy](https://github.com/elfassy)
* [Kelley Reynolds](https://github.com/kreynolds)
* [Washington L Braga Jr](https://github.com/huoxito)
* [mbradshawabs](https://github.com/mbradshawabs)
* [Richard Nuno](https://github.com/richardnuno)
* [Andres Camacho](https://github.com/andresfcamacho)
* [Yukio Mizuta](https://github.com/untidy-hair)
* [David Butler](https://github.com/dwbutler)
* [Jeroen K.](https://github.com/jrnkntl)
* [Masaya Myojin](https://github.com/mmyoji)
* [John Hawthorn](https://github.com/jhawthorn)
* [Ersin Akinci](https://github.com/earksiinni)
* [Bartosz Bonisławski](https://github.com/bbonislawski)
* [Harry Lascelles](https://github.com/hlascelles)
* [James Carscadden](https://github.com/JamesCarscadden)

# Related Material

## Usages

- [KIPU Health](https://kipuapi.com) (original use case)

## Libraries

- https://github.com/bwillis/versioncake
- https://github.com/EDMC/api-versions
- https://github.com/bploetz/versionist
- https://github.com/filtersquad/rocket_pants
- https://github.com/lyonrb/biceps

# Security issues?

If you think you have a security vulnerability, please submit the issue and the details to github issues.

# Questions?

Create a bug/enhancement/question on github or contact [SampsonCrowley](https://github.com/SampsonCrowley) through github.

# License

Version Cake is released under the MIT license: www.opensource.org/licenses/MIT
