function [ token ] = getToken( refresh )
% function [ token ] = getToken( refresh )
%   Function used to get authorization token from cloud server.
%   Generates a persistent variable named TOKEN to prevent repeated token
%   generations on repeated calls to the server.
%
% N. Rajan, 2015
% BSX Proprietary

OAuth_id = 'WEf7lFXcARobgUqG';
OAuth_Secret = 'mV1YoPTAFyWibtu0O5pOQQKPHkAq2ITv';
Base_URL = 'https://api.bsxinsight.com';   % production server
%Base_URL = 'http://devapi.bsxinsight.com';  % development server
OAuth_URL = [Base_URL '/access-token'];

persistent TOKEN;

if refresh || isempty(TOKEN)
    cmd = {'client_id' OAuth_id  'client_secret' OAuth_Secret 'grant_type' 'client_credentials' 'scope' 'matlab'};
    token_resp = parse_json(urlread(OAuth_URL, 'Post', cmd));
    TOKEN = token_resp.access_token;
end

token = TOKEN;

end


