import javax.swing.*;
import java.awt.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class TimeZoneConverter extends JFrame {

    private JTextField inputField;
    private JTextArea outputArea;
    private JLabel liveClockLabel;
    
    private final DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("HH:mm");
    private final DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("HH:mm:ss (z)");
    private final DateTimeFormatter liveFormatter = DateTimeFormatter.ofPattern("HH:mm:ss");

    public TimeZoneConverter() {
        setTitle("GST Timezone Pro");
        setSize(450, 450);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
        setLayout(new BorderLayout(10, 10));

        // 1. Menu Bar
        JMenuBar menuBar = new JMenuBar();
        JMenu fileMenu = new JMenu("File");
        JMenuItem exitItem = new JMenuItem("Exit");
        exitItem.addActionListener(e -> System.exit(0));
        fileMenu.add(exitItem);
        menuBar.add(fileMenu);
        setJMenuBar(menuBar);

        // 2. Live Clock Header
        JPanel headerPanel = new JPanel(new BorderLayout());
        headerPanel.setBackground(new Color(45, 45, 45));
        liveClockLabel = new JLabel("Loading GST...", SwingConstants.CENTER);
        liveClockLabel.setForeground(Color.CYAN);
        liveClockLabel.setFont(new Font("Monospaced", Font.BOLD, 20));
        headerPanel.add(liveClockLabel, BorderLayout.CENTER);
        
        // Start Live Timer
        Timer timer = new Timer(1000, e -> updateLiveClock());
        timer.start();

        // 3. Input Panel
        JPanel inputPanel = new JPanel(new GridLayout(3, 1, 5, 5));
        inputPanel.setBorder(BorderFactory.createEmptyBorder(10, 20, 10, 20));
        
        inputPanel.add(new JLabel("Enter Custom GST Time (HH:mm):"));
        inputField = new JTextField();
        inputPanel.add(inputField);

        JButton convertBtn = new JButton("Convert Custom Time");
        inputPanel.add(convertBtn);

        // 4. Output Area
        outputArea = new JTextArea();
        outputArea.setEditable(false);
        outputArea.setFont(new Font("Monospaced", Font.PLAIN, 13));
        JScrollPane scrollPane = new JScrollPane(outputArea);
        scrollPane.setBorder(BorderFactory.createTitledBorder("Conversion Results"));

        add(headerPanel, BorderLayout.NORTH);
        
        JPanel centerContainer = new JPanel(new BorderLayout());
        centerContainer.add(inputPanel, BorderLayout.NORTH);
        centerContainer.add(scrollPane, BorderLayout.CENTER);
        add(centerContainer, BorderLayout.CENTER);

        convertBtn.addActionListener(e -> convertTime());
    }

    private void updateLiveClock() {
        ZonedDateTime nowGst = ZonedDateTime.now(ZoneId.of("Asia/Dubai"));
        liveClockLabel.setText("LIVE GST: " + nowGst.format(liveFormatter));
    }

    private void convertTime() {
        try {
            String inputText = inputField.getText().trim();
            LocalTime localTime = LocalTime.parse(inputText, inputFormatter);
            ZonedDateTime gstTime = ZonedDateTime.of(LocalDate.now(), localTime, ZoneId.of("Asia/Dubai"));

            StringBuilder result = new StringBuilder();
            result.append(String.format("%-15s : %s\n", "GST (Source)", gstTime.format(outputFormatter)));
            result.append("------------------------------------------\n");
            
            result.append(formatZone(gstTime, "UTC"));
            result.append(formatZone(gstTime, "America/New_York")); 
            result.append(formatZone(gstTime, "Asia/Kolkata"));    
            result.append(formatZone(gstTime, "Asia/Tokyo"));      

            outputArea.setText(result.toString());

        } catch (DateTimeParseException ex) {
            JOptionPane.showMessageDialog(this, "Format Error! Use 24h format like 15:45");
        }
    }

    private String formatZone(ZonedDateTime baseTime, String zoneId) {
        ZonedDateTime converted = baseTime.withZoneSameInstant(ZoneId.of(zoneId));
        String shortName = zoneId.contains("/") ? zoneId.substring(zoneId.lastIndexOf("/") + 1) : zoneId;
        return String.format("%-15s : %s\n", shortName, converted.format(outputFormatter));
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new TimeZoneConverter().setVisible(true));
    }
}