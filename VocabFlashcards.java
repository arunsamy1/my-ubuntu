import javax.swing.*;
import javax.swing.text.html.HTMLEditorKit;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class VocabFlashcards extends JFrame {
    
    private static class Flashcard {
        String word;
        String meaning;
        Flashcard(String word, String meaning) {
            this.word = word;
            this.meaning = meaning;
        }
    }

    private JTextPane displayPane; // Switched to JTextPane for HTML support
    private JLabel progressLabel;
    private JButton revealButton, nextButton, prevButton, shuffleButton, resetButton;
    private List<Flashcard> cards = new ArrayList<>();
    private List<Flashcard> originalCards = new ArrayList<>(); 
    private int currentIndex = 0;
    private boolean isMeaningVisible = false;

    public VocabFlashcards() {
        setTitle("Vocab Builder Pro");
        setSize(600, 500);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        progressLabel = new JLabel("Please load a file to begin", SwingConstants.CENTER);
        progressLabel.setFont(new Font("SansSerif", Font.BOLD, 14));
        progressLabel.setBorder(BorderFactory.createEmptyBorder(10, 0, 10, 0));

        // Setup JTextPane for HTML
        displayPane = new JTextPane();
        displayPane.setEditable(false);
        displayPane.setEditorKit(new HTMLEditorKit());
        displayPane.setMargin(new Insets(60, 30, 60, 30));
        
        // Initial text
        updateDisplayText("Welcome!", "Open a file to start studying.");

        revealButton = new JButton("Show Meaning (Space)");
        prevButton = new JButton("Prev (P / ←)");
        nextButton = new JButton("Next (N / →)");
        shuffleButton = new JButton("Shuffle (S)");
        resetButton = new JButton("Reset Order (R)");
        
        JButton[] allButtons = {revealButton, prevButton, nextButton, shuffleButton, resetButton};
        for (JButton btn : allButtons) {
            btn.setFocusable(false);
            btn.setEnabled(false);
        }

        revealButton.addActionListener(e -> toggleMeaning());
        nextButton.addActionListener(e -> navigate(1));
        prevButton.addActionListener(e -> navigate(-1));
        shuffleButton.addActionListener(e -> shuffleCards());
        resetButton.addActionListener(e -> resetOrder());

        JButton loadButton = new JButton("Open File");
        loadButton.addActionListener(e -> loadVocabFile());

        JPanel controlPanel = new JPanel(new GridLayout(2, 1));
        JPanel row1 = new JPanel();
        JPanel row2 = new JPanel();

        row1.add(loadButton);
        row1.add(shuffleButton);
        row1.add(resetButton);
        row2.add(prevButton);
        row2.add(revealButton);
        row2.add(nextButton);

        controlPanel.add(row1);
        controlPanel.add(row2);

        add(progressLabel, BorderLayout.NORTH);
        add(new JScrollPane(displayPane), BorderLayout.CENTER);
        add(controlPanel, BorderLayout.SOUTH);

        setupKeyBindings();
        setLocationRelativeTo(null);
    }

    private void updateDisplayText(String word, String meaning) {
        // We use HTML to set different sizes for the Word and the Meaning
        String content;
        if (isMeaningVisible) {
            content = "<html><body style='text-align: center; font-family: Serif;'>"
                    + "<h1 style='font-size: 32pt; margin-bottom: 0;'>" + word + "</h1>"
                    + "<p style='font-size: 14pt; color: #555555; margin-top: 20px;'>Meaning:</p>"
                    + "<p style='font-size: 18pt; color: #0066CC;'>" + meaning + "</p>"
                    + "</body></html>";
        } else {
            content = "<html><body style='text-align: center; font-family: Serif;'>"
                    + "<h1 style='font-size: 32pt;'>" + word + "</h1>"
                    + "</body></html>";
        }
        displayPane.setText(content);
    }

    private void setupKeyBindings() {
        InputMap im = getRootPane().getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW);
        ActionMap am = getRootPane().getActionMap();

        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_SPACE, 0), "reveal");
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_N, 0), "next");
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_RIGHT, 0), "next");
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_P, 0), "prev");
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_LEFT, 0), "prev");
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_S, 0), "shuffle");
        im.put(KeyStroke.getKeyStroke(KeyEvent.VK_R, 0), "reset");

        am.put("reveal", new AbstractAction() { public void actionPerformed(ActionEvent e) { if(revealButton.isEnabled()) toggleMeaning(); } });
        am.put("next", new AbstractAction() { public void actionPerformed(ActionEvent e) { if(nextButton.isEnabled()) navigate(1); } });
        am.put("prev", new AbstractAction() { public void actionPerformed(ActionEvent e) { if(prevButton.isEnabled()) navigate(-1); } });
        am.put("shuffle", new AbstractAction() { public void actionPerformed(ActionEvent e) { if(shuffleButton.isEnabled()) shuffleCards(); } });
        am.put("reset", new AbstractAction() { public void actionPerformed(ActionEvent e) { if(resetButton.isEnabled()) resetOrder(); } });
    }

    private void loadVocabFile() {
        JFileChooser chooser = new JFileChooser();
        if (chooser.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
            originalCards.clear();
            try (BufferedReader br = new BufferedReader(new FileReader(chooser.getSelectedFile()))) {
                String line;
                while ((line = br.readLine()) != null) {
                    String[] parts = line.split("[,\\t;]"); 
                    if (parts.length >= 2) {
                        originalCards.add(new Flashcard(parts[0].trim(), parts[1].trim()));
                    }
                }
                if (!originalCards.isEmpty()) {
                    resetOrder();
                    setButtonsEnabled(true);
                }
            } catch (IOException ex) {
                JOptionPane.showMessageDialog(this, "Error loading file.");
            }
        }
    }

    private void shuffleCards() {
        if (cards.isEmpty()) return;
        Collections.shuffle(cards);
        currentIndex = 0;
        isMeaningVisible = false;
        updateDisplay();
    }

    private void resetOrder() {
        cards = new ArrayList<>(originalCards);
        currentIndex = 0;
        isMeaningVisible = false;
        updateDisplay();
    }

    private void toggleMeaning() {
        if (cards.isEmpty()) return;
        isMeaningVisible = !isMeaningVisible;
        updateDisplay();
    }

    private void navigate(int step) {
        if (cards.isEmpty()) return;
        currentIndex = (currentIndex + step + cards.size()) % cards.size();
        isMeaningVisible = false;
        updateDisplay();
    }

    private void updateDisplay() {
        Flashcard current = cards.get(currentIndex);
        progressLabel.setText("Card " + (currentIndex + 1) + " of " + cards.size());
        updateDisplayText(current.word, current.meaning);
        
        if (isMeaningVisible) {
            revealButton.setText("Hide Meaning");
        } else {
            revealButton.setText("Show Meaning (Space)");
        }
    }

    private void setButtonsEnabled(boolean state) {
        revealButton.setEnabled(state);
        nextButton.setEnabled(state);
        prevButton.setEnabled(state);
        shuffleButton.setEnabled(state);
        resetButton.setEnabled(state);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new VocabFlashcards().setVisible(true));
    }
}