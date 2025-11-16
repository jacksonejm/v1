/**
 * Figma Plugin Script: MyPath Onboarding Prototype Generator
 * ---------------------------------------------------------
 * Paste this file into a Figma plugin's `code.ts` (or run it inside the desktop
 * plugin sandbox) to auto-generate fully-labeled frames for every onboarding
 * step defined in `Docs/onboarding-field-map.md`.
 *
 * The script creates a horizontal storyboard with auto-layout-enabled frames,
 * complete with field controls, helper text, and message states. It is designed
 * so designers can immediately hook up prototype interactions without having to
 * redraw any UI scaffolding.
 */

type FieldType =
  | "text"
  | "textarea"
  | "select"
  | "multi-select"
  | "rating"
  | "display"
  | "loading"
  | "celebration";

type Variant =
  | "form"
  | "message"
  | "question"
  | "status";

interface OnboardingField {
  id: string;
  label: string;
  type: FieldType;
  required?: boolean;
  helperText?: string;
  options?: string[];
  selectionCount?: string;
}

interface OnboardingStep {
  id: string;
  title: string;
  subtitle?: string;
  variant: Variant;
  fields: OnboardingField[];
  description?: string;
}

const onboardingSteps: OnboardingStep[] = [
  {
    id: ".howDidYouHearAboutUs",
    title: "How did you hear about us?",
    subtitle: "Select one option",
    variant: "form",
    fields: [
      {
        id: "howDidYouHear",
        label: "Channel",
        type: "select",
        required: true,
        helperText: "Required. Includes an 'Other' option with free text.",
        options: [
          "Friend or family",
          "Counselor",
          "Social media",
          "School event",
          "Other"
        ]
      }
    ]
  },
  {
    id: ".getName",
    title: "Let's get to know you",
    subtitle: "Tell us your name",
    variant: "form",
    fields: [
      {
        id: "name",
        label: "Full name",
        type: "text",
        required: true,
        helperText: "Prefill example placeholder to speed up usability tests."
      }
    ]
  },
  {
    id: ".welcomeMessage",
    title: "Welcome, {name}!",
    subtitle: "We personalize everything for you",
    variant: "message",
    fields: [
      {
        id: "welcome",
        label: "Dynamic welcome card",
        type: "display",
        helperText: "No input — use this to highlight key onboarding benefits."
      }
    ]
  },
  {
    id: ".currentStatus",
    title: "What's your current status?",
    subtitle: "Choose one",
    variant: "form",
    fields: [
      {
        id: "currentStatus",
        label: "Current status",
        type: "select",
        required: true,
        options: [
          "Middle school student",
          "High school student",
          "College student",
          "Graduate",
          "Other"
        ],
        helperText: "Includes 'Other' text reveal logic."
      }
    ]
  },
  {
    id: ".studentLevel",
    title: "What's your student level?",
    variant: "form",
    fields: [
      {
        id: "studentLevel",
        label: "Select level",
        type: "select",
        required: true,
        options: [
          "Freshman",
          "Sophomore",
          "Junior",
          "Senior",
          "Other"
        ]
      }
    ]
  },
  {
    id: ".motivationalMessage",
    title: "You're on the right track",
    subtitle: "Motivational checkpoint",
    variant: "message",
    fields: [
      {
        id: "motivation",
        label: "Motivational card",
        type: "display",
        helperText: "Display-only — use branded illustration or quote."
      }
    ]
  },
  {
    id: ".interests",
    title: "What best describes you?",
    subtitle: "Pick exactly three",
    variant: "form",
    fields: [
      {
        id: "interests",
        label: "Interest chips",
        type: "multi-select",
        required: true,
        selectionCount: "Exactly 3",
        options: [
          "Problem Solver",
          "Maker",
          "Creative",
          "People helper",
          "Leader",
          "Organizer"
        ],
        helperText: "Lock CTA until three chips are active."
      }
    ]
  },
  ...["Realistic", "Investigative", "Artistic", "Social", "Enterprising", "Conventional"].map<OnboardingStep>(
    (dimension) => ({
      id: `.riasecQuestions.${dimension.toLowerCase()}`,
      title: `${dimension} RIASEC questions`,
      subtitle: "Rate each statement 1-5",
      variant: "question",
      fields: [
        {
          id: `${dimension.toLowerCase()}Questions`,
          label: `${dimension} prompts`,
          type: "rating",
          required: true,
          helperText: "Repeatable component with six question rows."
        }
      ]
    })
  ),
  {
    id: ".favoriteSubjects",
    title: "Favorite school subjects",
    subtitle: "Pick up to three",
    variant: "form",
    fields: [
      {
        id: "favoriteSubjects",
        label: "Subjects",
        type: "multi-select",
        selectionCount: "1-3",
        required: true,
        options: [
          "Math",
          "Science",
          "Art",
          "History",
          "English",
          "Technology",
          "Physical Education",
          "Other"
        ]
      }
    ]
  },
  {
    id: ".extracurriculars",
    title: "What do you do outside school?",
    subtitle: "Select all that apply",
    variant: "form",
    fields: [
      {
        id: "activities",
        label: "Activities",
        type: "multi-select",
        options: [
          "Robotics Club",
          "Drama",
          "Sports",
          "Debate",
          "Volunteering",
          "Music",
          "Other"
        ],
        helperText: "Optional step. Show text input when 'Other' is active."
      },
      {
        id: "activitiesOther",
        label: "Other activity",
        type: "text",
        helperText: "Hidden until 'Other' chip is selected."
      }
    ]
  },
  {
    id: ".careerInterests",
    title: "Careers you're curious about",
    subtitle: "Select all that apply",
    variant: "form",
    fields: [
      {
        id: "careerInterests",
        label: "Careers",
        type: "multi-select",
        options: [
          "Doctor",
          "Engineer",
          "Artist",
          "Entrepreneur",
          "Research Scientist",
          "Teacher",
          "Other"
        ],
        helperText: "Optional step with reveal input."
      },
      {
        id: "careerInterestsOther",
        label: "Other career",
        type: "text",
        helperText: "Free text, only visible when 'Other' is toggled."
      }
    ]
  },
  {
    id: ".loadingScreen",
    title: "Analyzing your answers",
    subtitle: "This takes just a few seconds",
    variant: "status",
    fields: [
      {
        id: "loading",
        label: "Loading indicator",
        type: "loading",
        helperText: "Use animated progress ring or dots."
      }
    ]
  },
  {
    id: ".completionScreen",
    title: "You're all set!",
    subtitle: "See your personalized matches",
    variant: "status",
    fields: [
      {
        id: "completion",
        label: "Completion card",
        type: "celebration",
        helperText: "Use confetti illustration + CTA to go to dashboard."
      }
    ]
  }
].flat();

const PRIMARY_FONT: FontName = { family: "Inter", style: "Bold" };
const SECONDARY_FONT: FontName = { family: "Inter", style: "Medium" };
const BODY_FONT: FontName = { family: "Inter", style: "Regular" };

const CANVAS_PADDING = 120;
const STEP_WIDTH = 420;
const STEP_MIN_HEIGHT = 640;
const CORNER_RADIUS = 24;

async function loadFonts() {
  await Promise.all([
    figma.loadFontAsync(PRIMARY_FONT),
    figma.loadFontAsync(SECONDARY_FONT),
    figma.loadFontAsync(BODY_FONT)
  ]);
}

function createTextNode(
  text: string,
  font: FontName,
  fontSize: number,
  color: RGB = { r: 0.08, g: 0.09, b: 0.15 }
): TextNode {
  const node = figma.createText();
  node.fontName = font;
  node.fontSize = fontSize;
  node.characters = text;
  node.fills = [{ type: "SOLID", color }];
  node.lineHeight = { unit: "AUTO" };
  return node;
}

function createFieldControl(field: OnboardingField): FrameNode {
  const wrapper = figma.createFrame();
  wrapper.layoutMode = "VERTICAL";
  wrapper.counterAxisSizingMode = "AUTO";
  wrapper.primaryAxisSizingMode = "AUTO";
  wrapper.itemSpacing = 8;
  wrapper.paddingTop = 0;
  wrapper.paddingBottom = 0;
  wrapper.paddingLeft = 0;
  wrapper.paddingRight = 0;
  wrapper.fills = [];

  const label = createTextNode(
    `${field.label}${field.required ? " *" : ""}`,
    SECONDARY_FONT,
    16
  );
  label.opacity = 0.9;
  wrapper.appendChild(label);

  const control = figma.createFrame();
  control.name = `${field.id}-control`;
  control.layoutMode = "VERTICAL";
  control.counterAxisSizingMode = "AUTO";
  control.primaryAxisSizingMode = "AUTO";
  control.paddingLeft = 20;
  control.paddingRight = 20;
  control.paddingTop = 16;
  control.paddingBottom = 16;
  control.cornerRadius = 16;
  control.strokes = [
    { type: "SOLID", color: { r: 0.83, g: 0.85, b: 0.9 } }
  ];
  control.strokeWeight = 1;
  control.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];

  const placeholder = createTextNode(
    placeholderText(field),
    BODY_FONT,
    14,
    { r: 0.36, g: 0.38, b: 0.44 }
  );
  control.appendChild(placeholder);

  if (field.options && field.options.length > 0) {
    const optionRow = figma.createFrame();
    optionRow.layoutMode = "HORIZONTAL";
    optionRow.primaryAxisSizingMode = "AUTO";
    optionRow.counterAxisSizingMode = "AUTO";
    optionRow.itemSpacing = 12;
    optionRow.fills = [];
    optionRow.paddingLeft = 0;
    optionRow.paddingRight = 0;
    optionRow.paddingTop = 8;
    optionRow.paddingBottom = 0;

    field.options.forEach((option) => {
      const chip = figma.createFrame();
      chip.layoutMode = "HORIZONTAL";
      chip.counterAxisSizingMode = "AUTO";
      chip.primaryAxisSizingMode = "AUTO";
      chip.paddingLeft = 16;
      chip.paddingRight = 16;
      chip.paddingTop = 8;
      chip.paddingBottom = 8;
      chip.cornerRadius = 100;
      chip.itemSpacing = 8;
      chip.fills = [
        { type: "SOLID", color: { r: 0.95, g: 0.96, b: 1 } }
      ];
      chip.strokes = [
        { type: "SOLID", color: { r: 0.74, g: 0.79, b: 1 } }
      ];
      chip.strokeWeight = 1;
      const chipText = createTextNode(option, BODY_FONT, 13);
      chipText.fontName = BODY_FONT;
      chip.appendChild(chipText);
      optionRow.appendChild(chip);
    });

    control.appendChild(optionRow);
  }

  if (field.selectionCount) {
    const badge = createTextNode(
      `Selection rule: ${field.selectionCount}`,
      BODY_FONT,
      12,
      { r: 0.36, g: 0.38, b: 0.44 }
    );
    control.appendChild(badge);
  }

  if (field.type === "loading") {
    control.resize(STEP_WIDTH - 80, 120);
    control.cornerRadius = 32;
    control.fills = [{ type: "SOLID", color: { r: 0.92, g: 0.95, b: 1 } }];
    const loadingText = createTextNode("Loading animation placeholder", BODY_FONT, 14);
    control.appendChild(loadingText);
  }

  if (field.type === "celebration") {
    control.resize(STEP_WIDTH - 80, 200);
    control.cornerRadius = 32;
    control.fills = [{ type: "SOLID", color: { r: 0.95, g: 0.98, b: 0.93 } }];
    const celebrationCopy = createTextNode(
      "Confetti illustration + primary CTA",
      BODY_FONT,
      14
    );
    control.appendChild(celebrationCopy);
  }

  if (field.helperText) {
    const helper = createTextNode(field.helperText, BODY_FONT, 12, {
      r: 0.36,
      g: 0.38,
      b: 0.44
    });
    helper.opacity = 0.9;
    wrapper.appendChild(control);
    wrapper.appendChild(helper);
  } else {
    wrapper.appendChild(control);
  }

  return wrapper;
}

function placeholderText(field: OnboardingField): string {
  switch (field.type) {
    case "text":
      return "Type response";
    case "textarea":
      return "Write your answer";
    case "select":
      return "Tap an option";
    case "multi-select":
      return "Select multiple options";
    case "rating":
      return "1 (Strongly Disagree) — 5 (Strongly Agree)";
    case "display":
      return "Display-only state";
    default:
      return "";
  }
}

function createStepFrame(step: OnboardingStep, index: number): FrameNode {
  const frame = figma.createFrame();
  frame.name = `${index + 1}. ${step.title}`;
  frame.resize(STEP_WIDTH, STEP_MIN_HEIGHT);
  frame.layoutMode = "VERTICAL";
  frame.counterAxisSizingMode = "AUTO";
  frame.primaryAxisSizingMode = "AUTO";
  frame.paddingLeft = 32;
  frame.paddingRight = 32;
  frame.paddingTop = 32;
  frame.paddingBottom = 32;
  frame.itemSpacing = 24;
  frame.cornerRadius = CORNER_RADIUS;
  frame.strokes = [
    { type: "SOLID", color: { r: 0.91, g: 0.93, b: 0.97 } }
  ];
  frame.strokeWeight = 1;
  frame.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  frame.effects = [
    {
      type: "DROP_SHADOW",
      color: { r: 0, g: 0, b: 0, a: 0.08 },
      offset: { x: 0, y: 8 },
      radius: 20,
      spread: 0,
      visible: true,
      blendMode: "NORMAL"
    }
  ];

  const stepLabel = createTextNode(step.id, BODY_FONT, 11, {
    r: 0.35,
    g: 0.37,
    b: 0.43
  });
  stepLabel.opacity = 0.8;
  frame.appendChild(stepLabel);

  const title = createTextNode(step.title, PRIMARY_FONT, 24);
  frame.appendChild(title);

  if (step.subtitle) {
    const subtitle = createTextNode(step.subtitle, BODY_FONT, 16, {
      r: 0.36,
      g: 0.38,
      b: 0.44
    });
    frame.appendChild(subtitle);
  }

  step.fields.forEach((field) => {
    const fieldNode = createFieldControl(field);
    frame.appendChild(fieldNode);
  });

  return frame;
}

async function run() {
  await loadFonts();

  const canvas = figma.createFrame();
  canvas.name = "MyPath Onboarding Prototype";
  canvas.layoutMode = "HORIZONTAL";
  canvas.counterAxisSizingMode = "AUTO";
  canvas.primaryAxisSizingMode = "AUTO";
  canvas.itemSpacing = 80;
  canvas.paddingLeft = CANVAS_PADDING;
  canvas.paddingRight = CANVAS_PADDING;
  canvas.paddingTop = CANVAS_PADDING / 2;
  canvas.paddingBottom = CANVAS_PADDING / 2;
  canvas.fills = [];
  canvas.strokes = [];

  onboardingSteps.forEach((step, index) => {
    const frame = createStepFrame(step, index);
    canvas.appendChild(frame);
  });

  figma.currentPage.appendChild(canvas);
  figma.viewport.scrollAndZoomIntoView([canvas]);
  figma.closePlugin("MyPath onboarding storyboard generated ✅");
}

run().catch((error) => {
  console.error(error);
  figma.closePlugin(`Failed to generate onboarding storyboard: ${error.message}`);
});
