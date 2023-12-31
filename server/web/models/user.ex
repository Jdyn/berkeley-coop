defmodule Berkeley.User do
  @moduledoc """
  Defines a User model to track and authenticate users across the application.
  """

  use Berkeley.Web, :model

  alias Berkeley.Chat.Room
  alias Berkeley.Event
  alias Berkeley.House
  alias Berkeley.User
  alias Berkeley.UserToken

  @registration_fields ~w(email username first_name last_name house_id)a

  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:role, :string, default: "user")
    field(:avatar, :string)
    field(:bio, :string)
    field(:username, :string)
    field(:last_seen, :utc_datetime, default: DateTime.truncate(DateTime.utc_now(), :second))

    field(:phone, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)

    field(:confirmed_at, :naive_datetime)

    field(:is_admin, :boolean, default: false)

    field(:hide_house, :boolean, default: false)
    field(:hide_name, :boolean, default: false)

    has_many(:tokens, UserToken)

    belongs_to(:house, House)

    # To implement joining a room as a user.
    many_to_many(:rooms, Room, join_through: "users_rooms")

    # To implement joining an event as a user.
    many_to_many(:events, Event, join_through: "participants_events")

    has_many(:created_events, Event, foreign_key: :creator_id)

    timestamps()
  end

  @doc """
  A user changeset for registration.
  It is important to validate the length of both e-mail and password.
  Otherwise databases may truncate the e-mail without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.
  """
  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @registration_fields ++ [:password, :bio])
    |> validate_required(@registration_fields ++ [:password])
    |> validate_email()
    |> validate_password()
  end

  def update_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :bio, :hide_house, :hide_name])
    |> validate_required([:username, :hide_house, :hide_name])
  end

  def oauth_registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @registration_fields)
    |> validate_required(@registration_fields)
    |> confirm_oauth_email(attrs.email_verified)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> update_change(:email, &String.downcase(&1))
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:email, max: 80)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 80)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> prepare_changes(&maybe_hash_password/1)
  end

  defp maybe_hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password_hash, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the e-mail.
  It requires the e-mail to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.
  """
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password()
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    change(user, confirmed_at: now)
  end

  def confirm_oauth_email(changeset, true) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    change(changeset, confirmed_at: now)
  end

  def confirm_oauth_email(changeset, false), do: add_error(changeset, :email_verified, "Email not verified")

  @doc """
  Verifies the password.
  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%User{password_hash: password_hash}, password)
      when is_binary(password_hash) and byte_size(password) > 0 do
    Pbkdf2.verify_pass(password, password_hash)
  end

  def valid_password?(_, _), do: Pbkdf2.no_user_verify()

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
