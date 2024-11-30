import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var settings: AppSettings
    @ObservedObject private var viewModel = LoginViewModel()
    @State private var openURLViewModel = ShowInAppBrowserViewModel()

    var body: some View {
        NavigationStack {
            List {
                R.image.loginAvatar.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .padding()
                    .frame(alignment: .center)
                    .plainListItem()
                
                VStack(alignment: .leading) {
                    Text("CREDENTIALS")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .frame(height: 40)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    
                    VStack {
                        HStack {
                            Text("Email")
                                .font(.headline)
                                .frame(maxWidth: 120)
                            
                            Spacer()
                            
                            ClearableTextField(
                                "",
                                secureType: false,
                                keyboardType: .emailAddress,
                                text: $viewModel.email
                            )
                            .frame(maxHeight: .infinity)
                        }
                        .frame(height: 44)
                        .padding(.horizontal, 16)
                        
                        Divider()
                            .padding(.leading)
                                                
                        HStack {
                            Text("Password")
                                .font(.headline)
                                .frame(maxWidth: 120)
                            
                            Spacer()
                            
                            ClearableTextField(
                                "",
                                secureType: true,
                                text: $viewModel.password
                            )
                            .frame(maxHeight: .infinity)
                        }
                        .frame(height: 44)
                        .padding(.horizontal, 16)
                    }
                    .background(UIColor.secondarySystemBackground.color)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .plainListItem()
                
                Button(action: viewModel.loginAction) {
                    if viewModel.loading {
                        ProgressView()
                    } else {
                        Text("Login")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(viewModel.loginButtonDisabled)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(UIColor.secondarySystemBackground.color)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 24)
                .plainListItem()
            }
            .alert("Incorrect Login", isPresented: $viewModel.showErrorAlert, actions: {
                Button(action: {
                    guard let url = URL(string: "https://non.io/admin/create-account") else { return }
                    openURLViewModel.handleURL(url)
                }, label: {
                    Text("Create account")
                        .fontWeight(.semibold)
                })
                
                Button(action: {

                }, label: {
                    Text("Try again")
                })
            }, message: {
                Text("Email or password incorrect")
            })
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Account")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .listRowSeparator(.hidden)
            .listStyle(.plain)
            .openURL(viewModel: openURLViewModel)
            .onChange(of: viewModel.loginResponse) { _, response in
                guard let response else { return }
                settings.currentUser = response
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        LoginScreen()
    }
}
