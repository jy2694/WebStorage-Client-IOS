import SwiftUI
import LocalAuthentication

struct LoginView: View {
    
    @State var remember : Bool = false
    @State var auto : Bool = false
    @State var id : String = ""
    @State var pw : String = ""
    @State var alertText: String = ""
    
    @Binding var ip : String
    @Binding var port : String
    @Binding var session: UUID?
    @Binding var fileStructure: [[String:String]]
    @Binding var logout: Bool
    
    func authenticate() {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "로그인을 위해 생체인증을 진행합니다."
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    if success {
                        guard let userdata = UserDefaultsManager.userData else { return }
                        HTTPClient.signInProc(ip: userdata.ip, port: userdata.port, id: userdata.id, pw: userdata.pw){ result in
                            switch result {
                            case .success(let uuid):
                                self.session = uuid
                                self.ip = userdata.ip
                                self.port = String(userdata.port)
                                HTTPClient.getFileListProc(ip: userdata.ip, port: userdata.port, session: uuid, path: "/"){ fileresult in
                                    switch fileresult{
                                    case .success(let structure):
                                        fileStructure = structure
                                    case .failure(_): break
                                    }
                                }
                            case .failure(let error):
                                switch error {
                                case .badURL:
                                    alertText = "Invalid Server Address"
                                case .decodingError:
                                    alertText = "Data Decoding Error"
                                case .noData:
                                    alertText = "Invalid Server Address"
                                case .permissionDenied:
                                    alertText = "Permission Denied"
                                case .unauthorized:
                                    alertText = "ID or PW Incorrect"
                                }
                            }
                        }
                    } else {
                        guard let userdata = UserDefaultsManager.userData else { return }
                        ip = userdata.ip
                        port = String(userdata.port)
                        id = userdata.id
                        auto = userdata.auto
                        remember = true
                    }
                }
            } else {
                auto = false
            }
        }
    
    func signIn() {
        guard let port = Int(port) else {
            alertText = "Invalid Port"
            return
        }
        alertText = ""
        HTTPClient.signInProc(ip: ip, port: port, id: id, pw: pw){ result in
            switch result {
            case .success(let uuid):
                self.session = uuid
                if remember {
                    UserDefaultsManager.userData = UserData(ip: ip, port: port, id: id, pw: pw, auto: auto)
                }
                HTTPClient.getFileListProc(ip: ip, port: port, session: uuid, path: "/"){ fileresult in
                    switch fileresult{
                    case .success(let structure):
                        fileStructure = structure
                    case .failure(_): break
                    }
                }
            case .failure(let error):
                switch error {
                case .badURL:
                    alertText = "Invalid Server Address"
                case .decodingError:
                    alertText = "Data Decoding Error"
                case .noData:
                    alertText = "Invalid Server Address"
                case .permissionDenied:
                    alertText = "Permission Denied"
                case .unauthorized:
                    alertText = "ID or PW Incorrect"
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Spacer()
                VStack{
                    Image(systemName: "lock.icloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding([.top], 10)
                    Text("WebStorage")
                        .font(.title2)
                        .padding([.bottom, .leading, .trailing], 10)
                }.overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.systemText, lineWidth: 1)
                )
                Spacer()
            }
            Spacer()
            HStack{
                VStack(alignment: .leading){
                    Text("Server : ")
                    TextField("", text: $ip)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            VStack{
                                if alertText == "Invalid Server Address" {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.red, lineWidth: 3)
                                }
                            }
                        )
                }
                VStack(alignment: .leading){
                    Text("Port : ")
                    TextField("", text: $port)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            VStack{
                                if alertText == "Invalid Port" || alertText == "Invalid Server Address" {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.red, lineWidth: 3)
                                }
                            }
                        )
                }
            }
            Text("ID : ")
            TextField("", text: $id)
                .textFieldStyle(.roundedBorder)
                .overlay(
                    VStack{
                        if alertText == "ID or PW Incorrect" {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.red, lineWidth: 3)
                        }
                    }
                )
            Text("PW : ")
            SecureField("", text: $pw)
                .textFieldStyle(.roundedBorder)
                .overlay(
                    VStack{
                        if alertText == "ID or PW Incorrect" {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.red, lineWidth: 3)
                        }
                    }
                )
            HStack{
                Spacer()
                Text(alertText)
                    .foregroundColor(.red)
                    .bold()
                Spacer()
            }
            HStack{
                Spacer()
                Button{
                    signIn()
                } label: {
                    Text("Sign In")
                        .padding([.top, .bottom], 5)
                        .padding([.leading, .trailing], 10)
                        .foregroundColor(.systemText)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.systemText, lineWidth: 1)
                )
                Spacer()
            }
            .padding()
            Spacer()
            HStack{
                Toggle(isOn: $remember, label: {
                    Text("로그인 정보 기억")
                })
                Toggle(isOn: $auto, label: {
                    Text("생체 인증 사용")
                })
                .onChange(of: auto){
                    if auto {
                        remember = true
                    }
                }
            }
        }
        .padding()
        .onAppear{
            guard let userdata = UserDefaultsManager.userData else { return }
            if userdata.auto && !logout{
                authenticate()
            } else {
                ip = userdata.ip
                port = String(userdata.port)
                id = userdata.id
                auto = userdata.auto
                remember = true
            }
        }
    }
}
