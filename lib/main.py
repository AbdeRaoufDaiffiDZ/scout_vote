import json
import os
from flask import Flask
from flask_socketio import SocketIO, emit

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

DATA_FILE = "votes_data.json"

def load_data():
    if os.path.exists(DATA_FILE):
        print(f"Full path to data file: {os.path.abspath(DATA_FILE)}")
        try:
            with open(DATA_FILE, "r") as f:
                return json.load(f)
        except:
            pass
    print(f"Full path to data file: {os.path.abspath(DATA_FILE)}")
    return {"ashbal": 0, "kashaf": 0, "mutaqadim": 0, "jawala": 0}

def save_data(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=4)

votes = load_data()

@socketio.on('connect')
def handle_connect():
    print(f"جهاز متصل. القيم الحالية: {votes}")
    emit('update_votes', votes)

@socketio.on('cast_vote')
def handle_vote(*args):
    global votes
    if not args:
        return
    
    # استلام البيانات (سواء كانت Tuple أو List)
    received_data = args
    # print(f"وصل تصويت جديد للخيارات التالية: {received_data}")

    # التحقق مما إذا كانت البيانات عبارة عن مجموعة (List أو Tuple)
    if isinstance(received_data, (list, tuple)):
        # تحديث كل خيار داخل المجموعة
        for category in received_data:
            if category in votes:
                votes[category] += 1
                # print(f"تم تحديث {category}: {votes[category]}")
            else:
                pass
                # print(f"تحذير: الخيار '{category}' غير موجود")
        
        # حفظ البيانات وإرسال التحديث
        save_data(votes)
        emit('update_votes', votes, broadcast=True)
        # print("تم تحديث ملف JSON وإرسال البيانات للديسكتوب ✅")
    else:
        # إذا كانت القيمة نصاً واحداً فقط (String)
        if received_data in votes:
            votes[received_data] += 1
            save_data(votes)
            emit('update_votes', votes, broadcast=True)
            # print(f"تم تحديث خيار منفرد: {received_data} ✅")
        else:
            pass
            # print(f"خطأ: نوع البيانات المستلمة ({type(received_data)}) غير مدعوم")
    
    print(votes)
if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)