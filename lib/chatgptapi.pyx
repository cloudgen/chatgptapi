import pickle
import base64
import requests

class ChatgptApi:
    def __init__(self):
        self.reset_content()
        self.host = "api.openai.com"
        self.enc_head = None
        self.enc_org = None

    def save_to_file(self, file_path):
        with open(file_path, 'wb') as file:
            pickle.dump(self, file)
            print(f"ChatgptApi object serialized and saved to: {file_path}")

    @staticmethod
    def load_from_file(file_path):
        try:
            with open(file_path, 'rb') as file:
                return pickle.load(file)
        except FileNotFoundError:
            print("File not found or couldn't be loaded.")
            return None

    def easey_encrypt(self, ip):
        b64encoded = base64.b64encode(ip.encode('utf-8')).decode('utf-8')

        # Reverse the string
        reverse = b64encoded[::-1]
        tmp = []
        OFFSET = 4
        for char in reverse:
            tmp.append(chr(ord(char) + OFFSET))
        return ''.join(tmp)

    def easey_decrypt(self, secret):
        tmp = []
        OFFSET = 4
        for char in secret:
            tmp.append(chr(ord(char) - OFFSET))
        reversed_str = ''.join(tmp)[::-1]
        return base64.b64decode(reversed_str).decode('utf-8')

    def reset_content(self):
        self.content_id = ''
        self.content = ''
        self.response_text = ''

    def reset_status_code(self):
        self.status_code=0
           
    def post_chat(self, content, model="gpt-3.5-turbo", role="user"):
        try:
            headers = {'Authorization': self.easey_decrypt(self.enc_head), 'OpenAI-Organization': self.easey_decrypt(self.enc_org)}
            post_data = {
                "model": model,
                "messages": [{
                    "role": role,
                    "content": content
                }]
            }
            self.reset_content()
            self.reset_status_code()
            self.set_urls()
            response = requests.post(self.chatgpt_chat_url, headers=headers, json=post_data)
            self.status_code = response.status_code
            self.response_text = response.text
            if self.status_code==200:
                api_response = response.json()
                self.content_id =  api_response.get('id')
                self.content = api_response.get('choices')[0]['message']['content']
            return response.text
        except requests.exceptions.RequestException as e:
            return f"Error making HTTP request: {str(e)}"

    def set_urls(self):
        self.chatgpt_chat_url = f"https://{self.host}/v1/chat/completions"
        
    def set_credentials(self, bearer, org):
        self.enc_head = self.easey_encrypt(f"Bearer {bearer}")
        self.enc_org = self.easey_encrypt(f"{org}")