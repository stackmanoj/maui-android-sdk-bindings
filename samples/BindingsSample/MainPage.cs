using BindingsSample.Services;

namespace BindingsSample;

public class MainPage : ContentPage
{
    private readonly Label _log = new() { Text = "Results will appear here.", FontSize = 13 };

    public MainPage()
    {
        Title = "Android SDK bindings";

        Content = new ScrollView
        {
            Content = new VerticalStackLayout
            {
                Padding = new Thickness(16),
                Spacing = 12,
                Children =
                {
                    new Label
                    {
                        Text = "Each button calls one binding with placeholder values. " +
                               "Edit SampleConfig.cs with real values from your provider and server.",
                        FontSize = 14
                    },
                    CreateButton("CCAvenue: open checkout", CCAvenueDemo.Start),
                    CreateButton("Mobikwik / Zaakpay: open checkout", ZaakpayDemo.Start),
                    CreateButton("Cashfree: UPI intent", () => CashfreeDemo.StartUpiIntent(Log)),
                    CreateButton("Facebook: log app event", () =>
                    {
                        FacebookDemo.LogSampleEvent();
                        Log("Facebook event logged.");
                    }),
                    _log
                }
            }
        };

        MainActivity.PaymentResult += message => MainThread.BeginInvokeOnMainThread(() => Log(message));
    }

    private Button CreateButton(string text, Action action)
    {
        var button = new Button { Text = text };
        button.Clicked += (_, _) =>
        {
            try
            {
                action();
            }
            catch (Exception ex)
            {
                Log($"{text} failed: {ex.GetType().Name}: {ex.Message}");
            }
        };
        return button;
    }

    private void Log(string message) =>
        _log.Text = $"{DateTime.Now:HH:mm:ss}  {message}\n{_log.Text}";
}
