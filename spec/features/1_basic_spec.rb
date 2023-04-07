require "rails_helper"

describe "The /movies page" do
  before do
    sign_in_user if user_model_exists?
  end

  it "can be visited", points: 1 do
    visit "/movies"

    expect(page.status_code).to be(200),
      "Expected to visit /movies successfully."
  end

  it "has a link to add a movie", points: 1 do
    visit "/movies"

    expect(page).to have_link('Add a new movie', href: "/movies/new"),
      "Expected /movies to have an 'Add a new movie' link to '/movies/new'."
  end

  it "has a bootstrap navbar", points: 1 do
    visit "/movies"

    expect(page).to have_selector("nav[class*='navbar']"),
    "Expected /movies to have a bootstrap navbar <nav> element with class='navbar'."
  end

  it "has margin top spacing with a bootstrap container class", points: 1 do
    visit "/movies"

    expect(page).to have_selector("div[class='container mt-3']"),
    "Expected /movies to have a <div class='container mt-3'> bootstrap container for adding margin top spacing."
  end
end

describe "The /movies/new page" do
  before do
    sign_in_user if user_model_exists?
  end

  it "can be visited", points: 1 do
    visit "/movies/new"

    expect(page.status_code).to be(200),
      "Expected to visit /movies/new successfully."
  end

  it "has a form", points: 1 do
    visit "/movies/new"

    expect(page).to have_selector("form[action='/movies']"),
      "Expected /movies/new to have a form with action='/movies'."
  end

  it "has a form that creates a movie record", point: 1 do
    old_movies_count = Movie.count
    visit "/movies/new"

    fill_in "Title", with: "My test movie"
    fill_in "Description", with: "description"
    click_button "Create Movie"

    new_movies_count = Movie.count
    
    expect(old_movies_count).to be < new_movies_count,
      "Expected 'Create Movie' form on /movies/new to successfully add a Movie record to the database."
  end

  it "displays a success notice flash message after creating movie", point: 1 do
    visit "/movies/new"

    fill_in "Title", with: "My test movie"
    fill_in "Description", with: "description"
    click_button "Create Movie"

    expect(page).to have_content("Movie created successfully."),
      "Expected to see the notice flash message 'Movie created successfully' after filling in and submitting the /movies/new form."
  end
end

describe "The movie details page" do
  let(:movie) { Movie.create(title: "My title", description: "My description") }

  before do
    sign_in_user if user_model_exists?
  end

  it "can be visited", points: 1 do
    visit "/movies/#{movie.id}"

    expect(page.status_code).to be(200),
      "Expected to visit /movies/ID successfully."
  end

  it "shows the movie on a bootstrap card", points: 2 do
    visit "/movies/#{movie.id}"

    expect(page).to have_selector("div[class='card']"),
      "Expected /movies/ID to have a <div class='card'> element to display the movie."
  end

  it "has a Font Awesome trash can icon to delete the movie", points: 2 do
    visit "/movies/#{movie.id}"

    expect(page).to have_selector("i[class='fa-regular fa-trash-can']"),
      "Expected /movies/ID to have a Font Awesome trash can icon on the card using the element <i class='fa-regular fa-trash-can'></i>."
  end

  it "deletes the movie with a DELETE request", points: 2 do
    visit "/movies/#{movie.id}"

    expect(page).to have_selector("a[href='/movies/#{movie.id}'][data-method='delete']"),
      "Expected /movies/ID to have 'Delete Movie' link with the proper data-method='delete'."
  end
end

describe "The movie edit page" do
  let(:movie) { Movie.create(title: "My title", description: "My description") }

  before do
    sign_in_user if user_model_exists?
  end

  it "can be visited", points: 1 do
    visit "/movies/#{movie.id}/edit"

    expect(page.status_code).to be(200),
      "Expected to visit /movies/ID/edit successfully."
  end

  it "has a form", points: 1 do
    visit "/movies/#{movie.id}/edit"

    expect(page).to have_selector("form[action='/movies/#{movie.id}'][method='post']"),
      "Expected /movies/ID/edit to have a form with action='/movies/ID' and method='post'."
  end

  it "has a hidden patch input", points: 2 do
    visit "/movies/#{movie.id}/edit"

    expect(page).to have_selector("input[name='_method'][value='patch']", visible: false),
      "Expected the edit movie form to have an input field of type='hidden' with name='_method' and value='patch'."
  end
end

describe "User authentication with the Devise gem" do
  it "requires sign in before any action with the Devise `before_action :authenticate_user!` method", points: 2 do
    visit "/movies/new"
    current_url = page.current_path

    expect(current_url).to eq(new_user_session_path),
      "Expected `before_action :authenticate_user!` in `ApplicationController` to redirect guest to /users/sign_in before visiting another page."
  end

  it "allows a user to sign up", points: 2 do
    old_users_count = User.count
    visit new_user_registration_path

    fill_in "Email", with: "user@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"

    new_users_count = User.count

    expect(old_users_count).to be < new_users_count,
      "Expected 'Sign up' form on /users/sign_up to successfully add a User record to the database."
  end
end

def sign_in_user
  user = User.create(email: "alice@example.com", password: "password")
  visit new_user_session_path

  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Log in"
end

def user_model_exists?
  Object.const_defined?("User")
end
