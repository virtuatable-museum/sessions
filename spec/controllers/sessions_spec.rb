RSpec.describe Controllers::Sessions do

  def app
    Controllers::Sessions.new
  end

  let!(:service) { create(:service) }
  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:premium_application) { create(:premium_application, creator: account) }
  let!(:application) { create(:application, creator: account) }

  describe 'POST /' do
    describe 'nominal case' do
      before do
        post '/sessions', {
          token: 'test_token',
          email: 'test@test.com',
          password: 'password',
          app_key: 'test_key'
        }
      end
      it 'Returns a 201 (Created) status code' do
        expect(last_response.status).to be 201
      end
      it 'Returns the correct body' do
        session = Arkaan::Authentication::Session.first
        expect(last_response.body).to include_json(
          token: session.token,
          created_at: session.created_at.utc.iso8601,
          account_id: account.id.to_s
        )
      end
    end

    it_should_behave_like 'a route', 'post', '/sessions'

    describe '400 errors' do
      describe 'no email error' do
        before do
          post '/sessions', {
            token: 'test_token',
            password: 'password',
            app_key: 'test_key'
          }
        end
        it 'Returns a 400 (Bad Request) status code' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct body' do
          expect(last_response.body).to include_json(
            status: 400,
            field: 'email',
            error: 'required',
          )
        end
      end
      describe 'no password error' do
        before do
          post '/sessions', {
            token: 'test_token',
            email: 'test@test.com',
            app_key: 'test_key'
          }
        end
        it 'Returns a 400 (Bad Request) status code' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 400,
            field: 'password',
            error: 'required',
          )
        end
      end
    end
    describe '403 errors' do
      describe 'non premium application access' do
        before do
          post '/sessions', {
            token: 'test_token',
            email: 'test@test.com',
            password: 'password',
            app_key: 'other_key'
          }
        end
        it 'Returns a 403 (Forbidden) status code' do
          expect(last_response.status).to be 403
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 403,
            field: 'app_key',
            error: 'forbidden'
          )
        end
      end
      describe 'wrong password given' do
        before do
          post '/sessions', {
            token: 'test_token',
            email: 'test@test.com',
            password: 'other_password',
            app_key: 'test_key'
          }
        end
        it 'Returns a 403 (Forbidden) status code' do
          expect(last_response.status).to be 403
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 403,
            field: 'password',
            error: 'wrong'
          )
        end
      end
    end
    describe '404 errors' do
      describe 'email not found' do
        before do
          post '/sessions', {
            token: 'test_token',
            email: 'fake@test.com',
            password: 'other_password',
            app_key: 'test_key'
          }
        end
        it 'Returns a 404 (Not Found) status code' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 404,
            field: 'email',
            error: 'unknown'
          )
        end
      end
    end
  end

  describe 'get /sessions/:id' do
    let!(:session) { create(:session, account: account) }
    let!(:url) { "/sessions/#{session.token}" }

    describe 'Nominal case, returns the correct session' do
      before do
        get "/sessions/#{session.token}", {
          app_key: 'test_key',
          token: 'test_token',
            session_id: session.token
        }
      end
      it 'returns a 200 (OK) status code' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json(
          token: 'session_token',
          created_at: session.created_at.utc.iso8601,
          account_id: account.id.to_s
        )
      end
    end

    it_should_behave_like 'a route', 'get', '/sessions/session_token'

    describe '403 errors' do
      describe 'application not authorized' do
        before do
          get url, {
            token: 'test_token',
            app_key: 'other_key',
            session_id: session.token
          }
        end
        it 'Returns a 403 (Forbidden) status code' do
          expect(last_response.status).to be 403
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 403,
            field: 'app_key',
            error: 'forbidden'
          )
        end
      end
    end
    describe '404 errors' do
      describe 'session not found' do
        before do
          get "/sessions/any_other_token", {
            token: 'test_token',
            app_key: 'test_key',
            session_id: session.token
          }
        end
        it 'Returns a 404 (Not Found) status code' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 404,
            field: 'session_id',
            error: 'unknown'
          )
        end
      end
    end
  end

  describe 'DELETE /:id' do
    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        delete '/sessions/session_token', {
          token: 'test_token',
          app_key: 'test_key',
          session_id: session.token
        }
      end
      it 'returns a 200 (OK) status code' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body' do
        expect(last_response.body).to include_json(message: 'deleted')
      end
    end

    it_should_behave_like 'a route', 'delete', '/sessions/session_token'

    describe '404 errors' do
      describe 'session not found' do
        before do
          delete '/sessions/any_other_token', {
            token: 'test_token',
            app_key: 'test_key',
            session_id: session.token
          }
        end
        it 'Returns a 404 (Not Found) status code' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json(
            status: 404,
            field: 'session_id',
            error: 'unknown'
          )
        end
      end
    end
  end
end