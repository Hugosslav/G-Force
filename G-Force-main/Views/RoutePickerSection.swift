import SwiftUI

/// Route assignment UI embedded in DriveDetailView: pick an existing named
/// route, or create a new one (name + a color from the fixed preset palette).
struct RoutePickerSection: View {
    @EnvironmentObject private var driveStore: DriveStore
    @Binding var selectedRouteID: UUID?
    let onChange: (UUID?) -> Void

    @State private var isCreatingRoute = false
    @State private var newRouteName = ""
    @State private var newRouteColorHex = Color.routePalette[0]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Route")
                .font(.headline)

            FlowChips {
                chip(name: "No route", color: .gray, isSelected: selectedRouteID == nil) {
                    select(nil)
                }

                ForEach(driveStore.routes) { route in
                    chip(name: route.name, color: route.color, isSelected: selectedRouteID == route.id) {
                        select(route.id)
                    }
                }

                chip(name: "+ New Route", color: .primary, isSelected: false) {
                    isCreatingRoute = true
                }
            }
        }
        .sheet(isPresented: $isCreatingRoute) {
            newRouteForm
        }
    }

    private func select(_ id: UUID?) {
        selectedRouteID = id
        onChange(id)
    }

    private func chip(name: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var newRouteForm: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Home to Office", text: $newRouteName)
                }
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(Color.routePalette, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if hex == newRouteColorHex {
                                        Circle().stroke(.primary, lineWidth: 2)
                                    }
                                }
                                .onTapGesture {
                                    newRouteColorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isCreatingRoute = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let route = driveStore.addRoute(name: newRouteName, colorHex: newRouteColorHex)
                        newRouteName = ""
                        isCreatingRoute = false
                        select(route.id)
                    }
                    .disabled(newRouteName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

/// Minimal wrapping "flow" layout for chips so the route list doesn't
/// require a fixed column count and wraps naturally at any width.
struct FlowChips: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
