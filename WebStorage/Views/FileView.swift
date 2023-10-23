//
//  FileView.swift
//  WebStorage
//
//  Created by 김제연 on 10/23/23.
//

import SwiftUI

struct FileView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var fileStructure : [[String:String]]
    @Binding var nowPath : String
    @Binding var history : [String]
    @Binding var ip: String
    @Binding var port: String
    @Binding var session: UUID?
    @Binding var logout: Bool
    @State var addType: Bool = false
    
    var body: some View {
        List {
            ForEach(fileStructure, id: \.self){ filedata in
                HStack{
                    Image(systemName: filedata["type"] == "file" ? "doc.text" : "folder")
                        .imageScale(.large)
                    Text(filedata["name"]!)
                    Spacer()
                    Text(filedata["filesize"]!)
                }
                .padding([.leading, .trailing], 10)
                .onTapGesture {
                    if filedata["type"]! == "directory" {
                        guard let port = Int(port) else {return}
                        history.append(nowPath)
                        if !nowPath.hasSuffix("/") {
                            nowPath = nowPath + "/"
                        }
                        nowPath = nowPath + filedata["name"]!
                        HTTPClient.getFileListProc(ip: ip, port: port, session: session!, path: nowPath){ fileresult in
                            switch fileresult{
                            case .success(let structure):
                                fileStructure = structure
                            case .failure(_): break
                            }
                        }
                    } else {
                        //Download Link Post
                    }
                }
            }
            HStack{
                Spacer()
                Image(systemName: "plus")
                Spacer()
            }
            .onTapGesture{
                addType.toggle()
            }
            .confirmationDialog("title", isPresented: $addType) {
                Button("Upload File") {
                    //File Upload Post
                    //File Structure Update Post
                    addType.toggle()
                }
                Button("Create Directory") {
                    //Directory Create Post
                    //File Structure Update Post
                    addType.toggle()
                }
                Button("Cancel", role: .cancel) {
                    addType.toggle()
                }
            } message: {
                Text("Please select the item you want to add")
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarLeading){
                Button {
                    nowPath = history.removeLast()
                    HTTPClient.getFileListProc(ip: ip, port: Int(port)!, session: session!, path: nowPath){ fileresult in
                        switch fileresult{
                        case .success(let structure):
                            fileStructure = structure
                        case .failure(_): break
                        }
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.systemText)
                }
                .disabled(history.count == 0)
            }
            ToolbarItem(placement: .topBarLeading){
                Text("\(nowPath)")
                    .lineLimit(1)
                    .truncationMode(.head)
            }
            ToolbarItem(placement: .topBarTrailing){
                Button {
                    HTTPClient.signOutProc(ip: ip, port: Int(port)!, session: session!){ result in
                        DispatchQueue.main.async{
                            logout = true
                            session = nil
                            dismiss()
                        }
                    }
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.systemText)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
