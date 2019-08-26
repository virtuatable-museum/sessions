RSpec.describe Controllers::Sessions do

  before do
    DatabaseCleaner.clean
    create(:service)
  end

  def app
    Controllers::Sessions.new
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:premium_application) { create(:premium_application, creator: account) }
  let!(:application) { create(:application, creator: account) }

  describe 'post /sessions' do

    describe 'nominal case' do
      before do
        post '/sessions', {token: 'test_token', username: 'Babausse', password: 'password', app_key: 'test_key'}.to_json
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
          expect(response_session['created_at']).to eq session.created_at.utc.iso8601
        end
        it 'returns the correct account ID for the user linked to the session' do
          expect(response_session['account_id']).to eq account.id.to_s
        end
      end
    end

    it_should_behave_like 'a route', 'post', '/sessions'

    describe 'bad request errors' do
      describe 'no username error' do
        before do
          post '/sessions', {token: 'test_token', password: 'password', app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the body doesn\'t contain the username' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body does not contain a username' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'username',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#username-not-given'
          })
        end
      end
      describe 'no password error' do
        before do
          post '/sessions', {token: 'test_token', username: 'Babausse', app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the body doesn\'t contain the password' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the body does not contain a password' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'password',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#password-not-given'
          })
        end
      end
    end
    describe 'forbidden errors' do
      describe 'non premium application access' do
        before do
          post '/sessions', {token: 'test_token', username: 'Babausse', password: 'password', app_key: 'other_key'}.to_json
        end
        it 'raises a forbidden (403) error when the given API key belongs to a non premium application' do
          expect(last_response.status).to be 403
        end
        it 'returns the correct body when application is not authorized to access the service' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 403,
            'field' => 'app_key',
            'error' => 'forbidden',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Common-errors#application-not-premium'
          })
        end
      end
      describe 'wrong password given' do
        before do
          post '/sessions', {token: 'test_token', username: 'Babausse', password: 'other_password', app_key: 'test_key'}.to_json
        end
        it 'raises a forbidden (403) error when the given password doesn\'t match the user password' do
          expect(last_response.status).to be 403
        end
        it 'returns the correct body when the password given does not match the user password' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 403,
            'field' => 'password',
            'error' => 'wrong',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#password-not-matching'
          })
        end
      end
    end
    describe 'not found errors' do
      describe 'username not found' do
        before do
          post '/sessions', {token: 'test_token', username: 'Another Username', password: 'other_password', app_key: 'test_key'}.to_json
        end
        it 'Raises a not found (404) error when the username doesn\'t belong to any known user' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body if the username is not belonging to any user' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 404,
            'field' => 'username',
            'error' => 'unknown',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#account-not-found'
          })
        end
      end
    end
  end

  describe 'get /sessions/:id' do
    let!(:session) { create(:session, account: account) }
    let!(:url) { "/sessions/#{session.token}" }

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
          expect(body['created_at']).to eq session.created_at.utc.iso8601
        end
        it 'returns the correct account ID for the user linked to the session' do
          expect(body['account_id']).to eq account.id.to_s
        end
      end
    end

    it_should_behave_like 'a route', 'get', '/sessions/session_token'

    describe 'forbidden errors' do
      describe 'application not authorized' do
        before do
          get url, {token: 'test_token', app_key: 'other_key'}
        end
        it 'Raises an forbidden (403) error when the application is not premium' do
          expect(last_response.status).to be 403
        end
        it 'returns the correct body when the application is not supposed to access this route' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 403,
            'field' => 'app_key',
            'error' => 'forbidden',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Common-errors#application-not-premium'
          })
        end
      end
    end
    describe 'not_found errors' do
      describe 'session not found' do
        before do
          get "/sessions/any_other_token", {token: 'test_token', app_key: 'test_key'}
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 404,
            'field' => 'session_id',
            'error' => 'unknown',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#session-not-found'
          })
        end
      end
    end
  end

  describe 'DELETE /:id' do
    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        delete '/sessions/session_token', {token: 'test_token', app_key: 'test_key'}
      end
      it 'returns a OK (200) response code if the session is successfully deleted' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body if the session is successfully deleted' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'deleted'})
      end
    end

    it_should_behave_like 'a route', 'delete', '/session_token'

    describe 'not_found errors' do
      describe 'session not found' do
        before do
          delete '/sessions/any_other_token', {token: 'test_token', app_key: 'test_key'}
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 404,
            'field' => 'session_id',
            'error' => 'unknown',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Sessions-API#session-not-found-1'
          })
        end
      end
    end
  end
end