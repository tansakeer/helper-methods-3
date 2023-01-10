# Helper Methods 3

The starting point of this project is a solution to Helper Methods after completing Parts 1 & 2.

## Setup

```
bin/setup
```

## Pull in Bootstrap, Font Awesome

Let's start to make this project look a little nicer. In the application layout:

- [Pull in Bootstrap CSS and Font Awesome with our quick-and-dirty CDN links.](https://chapters.firstdraft.com/chapters/788#quick-links-to-assets).
- [Add a Bootstrap navbar.](https://getbootstrap.com/docs/5.1/components/navbar/)
- For the `notice` and `alert`, switch to using [Bootstrap alerts](https://getbootstrap.com/docs/5.1/components/alerts/).
- Add [a Bootstrap `div.container`](https://getbootstrap.com/docs/5.2/layout/containers/) around the `yield` so that all of our templates are rendered within one.

## Partial view templates

Partial view templates (or just "partials", for short) are an extremely powerful tool to help us modularize and organize our view templates. Especially once we start adding in styling with Bootstrap, etc, our view files will grow to be hundreds or thousands of lines long, so it becomes increasingly helpful to break them up into partials.

### Official docs

[Here is the official article in the Rails API reference describing all the ways you can use partials.](https://edgeapi.rubyonrails.org/classes/ActionView/PartialRenderer.html) There are lots of powerful options available, but for now we're going to focus on the most frequently used ones.

### Getting started: static HTML partials

Create a partial view template in the same way that you create a regular view template, except that the first letter in the file name _must_ be an underscore. This is how we (and Rails) distinguish partial view templates from full view templates.

For example, create a file called `app/views/zebra/_giraffe.html.erb`. Within it, write the following:

```html
<h1>Hello from the giraffe partial!</h1>
```

Then, in any of your other view templates, e.g. `movies/index`, add:

```html
<%= render template: "zebra/giraffe" %>
```

Notice that **we don't include the underscore when referencing the partial** in the `render` method, even though the underscore must be present in the actual filename.

You can render the partial as many times as you want:

```html
<%= render template: "zebra/giraffe" %>

<hr>

<%= render template: "zebra/giraffe" %>
```

A more realistic example of putting some static HTML into a partial is extracting a 200 line Bootstrap navbar into `app/views/shared/_navbar.html.erb` and then `render`ing it from within the application layout. Try doing that now.

### Partials with inputs

Breaking up large templates by putting bits of static HTML into partials is nice, but even better is the ability to dynamically render partials based on varying inputs.

For example, create a file called `app/views/zebra/_elephant.html.erb`. Within it, write the following:

```erb
<h1>Hello, <%= person %>!</h1>
```

Then, in `movies/index`, try:

```erb
<%= render template: "zebra/elephant" %>
```

When you test it, it will break and complain about an undefined local variable `person`. To fix it, try:

```erb
<%= render template: "zebra/elephant", locals: { person: "Alice" } %>
```

Now it becomes more clear why it can be useful to render the same partial multiple times:

```erb
<%= render template: "zebra/elephant", locals: { person: "Alice" } %>

<hr>

<%= render template: "zebra/elephant", locals: { person: "Bob" } %>
```

If we think of rendering partials as _calling methods that return HTML_, then the `:locals` option is how we _pass in arguments_ to those methods. This allows us to create powerful, reusable HTML components.

### Form partials

In this application, can you find any ERB that's re-used in multiple templates?

Well, since we evolved to using `form_with model: @movie`, the two forms in `movies/new` and `movies/edit` are exactly the same!

1. Let's extract the common ERB into a template called `app/views/movies/_form.html.erb`.
1. Then render it from both places with:

    ```erb
    render template: "movies/form"
    ```
    
If you test it out, you'll notice that it works. However, we're kinda getting lucky here that we named our instance variable the same thing in both actions —— `@movie`. Try making the following variable name changes in `MoviesController`:

```rb
def new
  @new_movie = Movie.new # instead of @movie
end

def edit
  @the_movie = Movie.find(params.fetch(:id)) # instead of @movie
end
```

Now if you test it out, you'll get errors complaining about undefined methods for `nil`, since the `movies/_form` partial expects an instance variable called `@movie` and we're no longer providing it.

So, should we always just use the same exact variable name everywhere? That's not very flexible, and sometimes it's just not possible. Instead, we should use the `:locals` option:

Update the `form` partial to use an arbitrary local variable name, e.g. `foo`, rather than `@movie`:

```erb
<%= form_with model: foo do |form| %>
```

If you test it out now, you'll get the expected "undefined local variable `foo`" error.

But then, update `movies/new`:

```erb
<%= render template: "movies/form", locals: { foo: @new_movie } %>
```

And `movies/edit`:

```erb
<%= render template: "movies/form", locals: { foo: @the_movie } %>
```

If you test it out, everything should be working again. And, it's much better, because the `movies/_form` partial is flexible enough to be called from any template, or multiple times within the same template (e.g. if we wanted to have multiple comment forms on a photos index page).

So, a rule of thumb: **don't use instance variables within partials**. Instead, prefer to use the `:locals` option and pass in any data that the partial requires, even though it's more verbose to do it that way.

### ActiveRecord object partials

Rendering an HTML representation of a record from our database is the most common work we do in a CRUD web app. As you might expect, Rails provides several handy shortcuts for doing this efficiently with partials. Let's experiment!

#### Bootstrap one movie

First, let's improve `movies#show` to make use of [a Bootstrap card](https://getbootstrap.com/docs/5.1/components/card/) and [some Font Awesome icons](https://fontawesome.com/search?o=r&m=free):

```html
<div class="card">
  <div class="card-header">
    <%= link_to "Movie ##{@movie.id}", @movie %>
  </div>

  <div class="card-body">
    <dl>
      <dt>
        Title
      </dt>
      <dd>
        <%= @movie.title %>
      </dd>

      <dt>
        Description
      </dt>
      <dd>
        <%= @movie.description %>
      </dd>
    </dl>

    <div class="row">
      <div class="col">
        <div class="d-grid">
          <%= link_to edit_movie_path(@movie), class: "btn btn-outline-secondary" do %>
            <i class="fa-regular fa-pen-to-square"></i>
          <% end %>
        </div>
      </div>
      <div class="col">
        <div class="d-grid">
          <%= link_to @movie, method: :delete, class: "btn btn-outline-secondary" do %>
            <i class="fa-regular fa-trash-can"></i>
          <% end %>
        </div>
      </div>
    </div>
  </div>

  <div class="card-footer">
    Last updated <%= time_ago_in_words(@movie.updated_at) %> ago
  </div>
</div>
```

#### Constrain the size with the grid

Let's add [a Bootstrap grid row and cell](https://getbootstrap.com/docs/5.2/layout/grid/) to `movies#show` to constrain the card a bit:

```html
<div class="row">
  <div class="col-md-6 offset-md-3">
      
    <!-- code for movie card in here -->
   
  </div>
</div>
```

#### Cards in index

Now that we've styled one movie nicely, can we use the same styling on the index page? We _could_ copy-paste the ERB over from `movies#show`, but there's a better way:

1. Make a partial called `movies/_movie_card.html.erb`.
2. Copy the ERB that represents one movie from `movies#show` into this new partial.
3. In the partial, wherever we were referencing the instance variable that was defined by `movies#show` (`@movie`), replace with a local variable (let's  call it `baz`).
4. Render the partial within `movies#show`:

    ```html
      <%= render partial: "movies/movie_card", locals: { baz: @movie } %>
    ```
5. Re-use the partial in `movies#index`:

    ```html
    <% @movies.each do |movie| %>
      <%= render partial: "movies/movie_card", locals: { baz: movie } %>
    <% end %>
    ```
6. Constrain the size of each card with grid classes:

    ```html
    <div class="row">
      <% @movies.each do |movie| %>
        <div class="col-md-3">
          <%= render partial: "movies/movie_card", locals: { baz: movie } %>
        </div>
      <% end %>
    </div>
    ```

Neat! Now if we change the appearance of the movie card, or add an attribute, we only have to change it in one place.

### Partials shine along with Jump To File

In addition to all the other benefits, partials really help you get around your codebase efficiently. For example, if you need to make a change to the navbar, rather than going to the application layout file and digging around, you can use the Jump To File keyboard shortcut (Windows: Ctrl+P, Mac: Cmd+P). Start typing the name of the file — VSCode fuzzily matches what you type and usually finds the right file within a few characters. Hit <kbd>return</kbd> and boom you're transported to just where you want to be.

If you're still manually clicking files and folders in the sidebar, start trying to get used to navigating with Jump To File instead.

## before_action

Read about [controller filters](https://guides.rubyonrails.org/action_controller_overview.html#filters). [Where have we seen this technique before?](https://chapters.firstdraft.com/chapters/888#current_user)

In this application, try using `before_action` to DRY up the repetition we see with:

```
@movie = Movie.find(params.fetch(:id))
```

being repeated in the `show`, `edit`, `update`, and `destroy` actions. In order for this trick to work, we must use the same instance variable name in all four actions. This is a double-edged sword — relying on the same variable name isn't very flexible, but it does allow us to eliminate a lot of repeated code.

## Generate a scaffold

Try using the built-in `scaffold` generator to spin up another resource, e.g. directors:

```
rails g scaffold director name dob:date bio:text
```

Carefully read through all of the code that was generated. Do you understand all of it now? Ask questions about anything that's fuzzy.

## Solutions

You can see my solutions for this project in [this pull request](https://github.com/appdev-projects/helper-methods-3/pull/1/files).
