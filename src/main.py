from lib.chatgptapi import ChatgptApi

if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1:
        if sys.argv[1] == "setauth":
            bearer = input("Enter bearer: ")
            org_id = input("Enter organization id: ")
            chatgpt_api = ChatgptApi()
            chatgpt_api.set_credentials(bearer, org_id)
            chatgpt_api.save_to_file("chatgptapi.data")
        elif sys.argv[1] == "chat":
            chatgpt_api = ChatgptApi.load_from_file("chatgptapi.data")
            if chatgpt_api and chatgpt_api.enc_head and chatgpt_api.enc_org:
                # Modify these parameters as needed for your post
                content="When is ChatGPT invented?"
                if len(sys.argv) > 2:
                    content=sys.argv[2]
                chatgpt_api.post_chat(content)
                print(f"Status Code: {chatgpt_api.status_code}")
                print(f"Content: {chatgpt_api.content}")
            else:
                print("Could not load ChatgptApi object from file.")
    else:
        print("Usage: python main.py [setauth|chat]")