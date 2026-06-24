from itertools import count

from PySide6.QtCore import Qt, QModelIndex, QAbstractListModel, QThread

class FileRoles:
    IdRole = Qt.UserRole + 0
    NameRole = Qt.UserRole + 1
    directionRole = Qt.UserRole + 2
    PathRole = Qt.UserRole + 3
    SizeRole = Qt.UserRole + 4
    receivedRole = Qt.UserRole + 5
    sendedRole = Qt.UserRole + 6

class FileListModel(QAbstractListModel):
    def __init__(self, files=None):
        super().__init__()
        self._files = files or []
        self._nextId = count()

    def roleNames(self):
        return {
            FileRoles.IdRole: b"id",
            FileRoles.directionRole: b"direction",
            FileRoles.NameRole: b"fileName",
            FileRoles.PathRole: b"filePath",
            FileRoles.SizeRole: b"fileSize",
            FileRoles.receivedRole: b"bytesReceived",
            FileRoles.sendedRole: b"bytesSended",
        }
    def rowCount(self, parent=QModelIndex()):
        return len(self._files)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None

        item = self._files[index.row()]

        if role == FileRoles.IdRole:
            return item["id"]
        elif role == FileRoles.directionRole:
            return item["direction"]
        elif role == FileRoles.NameRole:
            return item["fileName"]
        elif role == FileRoles.PathRole:
            return item["filePath"]
        elif role == FileRoles.SizeRole:
            return item.get("fileSize", 0)
        elif role == FileRoles.receivedRole:
            return item["bytesReceived"]
        elif role == FileRoles.sendedRole:
            return item.get("bytesSended", 0)
        
        return None
            
    def addFile(self, name, path, size, direction):
        row = len(self._files)
        print(QThread.currentThread())
        print("--BEFORE ADDING:--", self.rowCount())

        print("** ADDING TO MODEL: **", name, "with size:", size, "and path:", path, "direction:", direction)
        self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
        self._files.append({
            "id": next(self._nextId),
            "fileName": name,
            "filePath": path,
            "fileSize": size,
            "direction": direction,
            "bytesReceived": 0,
            "bytesSended": 0
        })
        self.endInsertRows()

        

        print("--NEW MODEL:-- ")
        print("items: ", self.rowCount())
        print(self._files)  # Debugging: print the current state of the model after adding a file
        
        return self.index(row, 0)
    
    def setData(self, index, value, role=Qt.EditRole):
        if not index.isValid():
            return False

        item = self._files[index.row()]

        if role == FileRoles.receivedRole:
            item["bytesReceived"] = value
            print(f"Updated bytesReceived for {item['fileName']} to {value}")
        elif role == FileRoles.sendedRole:
            item["bytesSended"] = value
        else:
            return False

        self.dataChanged.emit(index, index, [role])
        return True

    def removeFile(self, id):
        for row, file in enumerate(self._files):
            if file["id"] == id:
                self.beginRemoveRows(QModelIndex(), row, row)
                self._files.remove(file)
                self.endRemoveRows()
                print(f"Removed file with id: {id}. Current model size: {self.rowCount()}")
                return