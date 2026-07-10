import SwiftUI

/// The colored, tappable route banner at the top of the Detail screen.
/// Tapping it opens the route picker/creation flow as a sheet.
struct RouteBanner: View {
    @EnvironmentObject private var driveStore: DriveStore
    @Binding var selectedRouteID: UUID?
    let onChange: (UUID?) -> Void

    @State private var isShowingPicker = false

    private var route: Route? {
        guard let selectedRouteID else { return nil }
        return driveStore.routes.first { $0.id == selectedRouteID }
    }

    var body: some View {
        Button {
            isShowingPicker = true
        } label: {
            HStack {
                Text(route?.name ?? "No Route Selected")
                    .font(.headline)
                    .foregroundStyle(route == nil ? Color.secondary : Color.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(route == nil ? Color.secondary : Color.white.opacity(0.8))
            }
            .padding()
            .background(route?.color ?? Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShowingPicker) {
            NavigationStack {
                RoutePickerSection(selectedRouteID: $selectedRouteID, onChange: onChange)
                    .padding()
                    .navigationTitle("Route")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { isShowingPicker = false }
                        }
                    }
            }
        }
    }
}
