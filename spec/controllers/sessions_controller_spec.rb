RSpec.describe SessionsController do

  before do
    DatabaseCleaner.clean
    create(:service)
  end

  def app
    SessionsController.new
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:premium_application) { create(:premium_application, creator: account) }
  let!(:application) { create(:application, creator: account) }

  describe 'post /sessions' do

    describe 'nominal case' do
      before do
        post '/', {token: 'test_token', username: 'Babausse', password: 'password', app_key: 'test_key'}.to_json
      end
      it 'Correctly creates a session when every parameter are alright' do
        expect(last_response.status).to be 201
      end
      describe 'response format' do
        let!(:session) { Arkaan::Authentication::Session.first }
        let!(:response_session) { JSON.parse(last_response.body) }

        it 'Returns the correct token for the created session' do
          expect(response_session['token']).to eq session.token
        end
        it 'returns the right creation date for the created session' do
          expect(response_session['created_at']).to eq session.created_at.to_s
        end
        it 'returns the correct account ID for the user linked to the session' do
          expect(response_session['account_id']).to eq account.id.to_s
        end
      end
    end

    it_should_behave_like 'a route', 'post', '/'

    describe 'bad request errors' do
      describe 'no username error' do
        before do
          post '/', {token: 'test_token', password: 'password', app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the body doesn\'t contain the username' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body does not contain a username' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.username'})
        end
      end
      describe 'no password error' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the body doesn\'t contain the password' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body does not contain a password' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.password'})
        end
      end
    end
    describe 'unauthorized errors' do
      describe 'non premium application access' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', password: 'password', app_key: 'other_key'}.to_json
        end
        it 'raises a unauthorized (401) error when the given API key belongs to a non premium application' do
          expect(last_response.status).to be 401
        end
        it 'returns the correct body when application is not authorized to access the service' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_authorized'})
        end
      end
    end
    describe 'forbidden errors' do
      describe 'wrong password given' do
        before do
          post '/', {token: 'test_token', username: 'Babausse', password: 'other_password', app_key: 'test_key'}.to_json
        end
        it 'raises a forbidden (403) error when the given password doesn\'t match the user password' do
          expect(last_response.status).to be 403
        end
        it 'returns the correct body when the password given does not match the user password' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'wrong_password'})
        end
      end
    end
    describe 'not found errors' do
      describe 'username not found' do
        before do
          post '/', {token: 'test_token', username: 'Another Username', password: 'other_password', app_key: 'test_key'}.to_json
        end
        it 'Raises a not found (404) error when the username doesn\'t belong to any known user' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body if the username is not belonging to any user' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'account_not_found'})
        end
      end
    end
  end

  describe 'get /sessions/:id' do
    let!(:session) { create(:session, account: account) }
    let!(:url) { "/#{session.token}" }

    describe 'Nominal case, returns the correct session' do
      before do
        get "#{url}?app_key=test_key&token=test_token"
      end
      it 'returns a 200 code when the route is correctly called' do
        expect(last_response.status).to be 200
      end
      describe 'Response body parameters' do
        let!(:body) { JSON.parse(last_response.body) rescue {} }

        it 'returns the right token for the session' do
          expect(body['token']).to eq 'session_token'
        end
        it 'returns the right creation date for the session' do
          expect(body['created_at']).to eq session.created_at.to_s
        end
        it 'returns the correct account ID for the user linked to the session' do
          expect(body['account_id']).to eq account.id.to_s
        end
      end
    end

    it_should_behave_like 'a route', 'get', '/session_token'

    describe 'unauthorized errors' do
      describe 'application not authorized' do
        before do
          get url, {token: 'test_token', app_key: 'other_key'}
        end
        it 'Raises an unauthorized (401) error when the application is not premium' do
          expect(last_response.status).to be 401
        end
        it 'returns the correct body when the application is not supposed to access this route' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_authorized'})
        end
      end
    end
    describe 'not_found errors' do
      describe 'session not found' do
        before do
          get "/any_other_token", {token: 'test_token', app_key: 'test_key'}
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'session_not_found'})
        end
      end
    end
  end
end