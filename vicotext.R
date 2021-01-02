# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# Source Code File: vicotext.R for OTA/VICO User Information and Interface Functions
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO Subprograms
# - User Interface (UI) Text Functions (for Beta 2 UX Purposes)
# --- otaintrorealtop
# --- limitationsnow
# --- callforfeedbacknow
# --- feedbacknow
# --- disclaimernow
# --- considerationsnow
# --- furtherdetailsnow
# - User Interface (UI) Text Functions for Program Information Page
# --- abouttop
# --- credits
# --- engineversion
# --- funding
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO - User Interface (UI) Text Functions (for Beta 2 UX Purposes)
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# otaintrorealtop
# limitationsnow
# callforfeedbacknow
# feedbacknow
# disclaimernow
# considerationsnow
# furtherdetailsnow
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
otaintrorealtop <- function() {
  list(
    tags$div(style = "padding:2px 10px 5px 10px;text-align: center;font-size: 22px;",
             tags$span(
               style = "color: black;",
               tags$strong("VICO Beta-2")
             )
    ),
    tags$div(style = "padding: 0px 14% 5px 14%;text-align: center;font-size: 14px;",
             tags$span(
               style = "color: black;",
               tags$em("Developed by the Chesapeake Bay Program Office in collaboration with the Chesapeake Research Consortium.")
             )
    ),
    tags$div(style = "padding: 5px 14% 0px 14%;text-align: center;font-size: 14px;",
             tags$span(
               style = "color: black;",
               paste0("The Visualization Interface for Chesapeake Optimization ",
                      "(VICO) helps identify strategies for minimizing costs and/or maximizing nutrient load reductions ",
                      "in the Chesapeake Assessment Scenario Tool (CAST)."
               )
             )
    )
  )
}
limitationsnow <- function() {
  list(
    tags$div(style = "padding: 10px 10px 0px 10px;text-align: center;font-size: 16px;",
             tags$span(style = "color: black;",
                       tags$strong("Limitations Disclaimer"))),
    tags$div(
      style = "padding: 0px 14% 0px 14%;text-align: center;font-size: 14px;",
      tags$span(
        style = "color: black;",
        paste0(
          "This Beta-2 release has significant limitations and is intended primarily ",
          "for testing and gathering feedback. ",
          "Unlike CAST, it is "
        ),
        tags$strong("limited to Efficiency BMPs only."),
        " It is important to review "
      ),
      tags$span(style = "color: black;",
                tags$a(href = '#important', 'additional disclaimers and notes below')
      ),
      tags$span(
        style = "color: black;",
        "before using this tool."
      )
    )
  )
}
callforfeedbacknow <- function() {
  list(
    tags$div(style = "padding: 10px 10px 0px 10px;text-align: center;font-size: 16px;",
             tags$span(
               style = "color: black;",
               tags$strong("We Need Your Feedback!")
             )),
    tags$div(
      style = "padding: 0px 14% 15px 14%;text-align: center;font-size: 14px;",
      tags$span(
        style = "color: black;",
        paste0("The success of this tool depends on your feedback! ")
      ),
      tags$span(style = "color: black;",
                # kwa on 12/29/20 - replace Daniel Kaufman with Lewis Linker
                # kwa on 12/29/20 - replace dkaufman@chesapeakebay.net with linker.lewis@epa.gov
                HTML(
                  paste0(
                    'Please send comments or questions to Lewis Linker at ',
                    tags$a(href = 'mailto:linker.lewis@epa.gov', 'linker.lewis@epa.gov'),
                    '.'
                  )
                )),
      tags$span(style = "color: black;",
                tags$em(
                  paste0("Your help in this regard is greatly appreciated! ")
                ))
    )
  )
}
feedbacknow <- function() {
  list(
  tags$div(
    style = "padding: 10px 14% 1px 14%;text-align: center;font-size: 14px;",
    tags$span(
      style = "color: black;",
      paste0("Send feedback about bugs, glitches, lack of functionality, or other issues on the website to:")
    )
  ),
  tags$div(
    style = "padding: 1px 14% 1px 14%;text-align: center;font-size: 14px;",
    tags$span(style = "color: black;",
              # kwa on 12/29/20 - replace dkaufman@chesapeakebay.net with linker.lewis@epa.gov
              HTML(
                paste0(
                  tags$a(href = 'mailto:linker.lewis@epa.gov', 'linker.lewis@epa.gov')
                )
              ))
  ),
  tags$div(
    style = "padding: 1px 14% 5px 14%;text-align: center;font-size: 14px;",
    tags$span(style = "color: black;",
              tags$em(
                paste0("Thanks for helping improve this program!")
              ))
  )
  )
}
disclaimernow <- function() {
  list(
    tags$div(style = "padding: 10px 14% 5px 14%;font-size: 14px;",
             tags$span(style = "color: black;",
                       tags$a(id = 'important'),
                       tags$strong("Disclaimer:"))),
    tags$div(style = "padding: 2px 14% 5px 14%;font-size: 14px;",
             tags$span(
               style = "color: black;",
               paste0(
                 "This VICO beta version in the process of being tested. ",
                 "It is provided on an “as is” and “as available” basis and is believed to contain defects. ",
                 "A primary purpose of this beta testing release is to solicit feedback on performance and defects. ",
                 "The Chesapeake Bay Program Office (CBPO) does not give any express or implied warranties of any kind, ",
                 "including warranties of suitability or usability of the website, its software, or any of its content, ",
                 "or warranties of fitness for any particular purpose."
               )
             )),
    tags$div(style = "padding: 5px 14% 5px 14%;font-size: 14px;",
             tags$span(
               style = "color: black;",
               paste0(
                 "All users of VICO are advised to safeguard important data, to use caution, and not to rely in any way ",
                 "on correct functioning or performance of the beta release and/or accompanying materials. ",
                 "CBPO will not be liable for any loss (including direct, indirect, special, or consequential losses) ",
                 "suffered by any party as a result of the use of or inability to use the VICO web application, ",
                 "its software, or its content, even if CBPO has been advised of the possibility of such loss."
               )
             ))
  )
}
considerationsnow <- function() {
  list(
    tags$div(style = "padding: 5px 14% 5px 14%;font-size: 14px;",
             tags$span(
               style = "color: black;",
               tags$strong("Additional Considerations and Limitations:")
             )),
             tags$div(style = "padding: 2px 14% 5px 14%;font-size: 14px;",
                      tags$ul(
      tags$li(
        paste0(
          "This Beta version is in the process of being tested and is not intended for use in ",
          "Phase III WIP development because of potential defects and limitations, known and unknown."
        )
      ),
      tags$li(style = "color: maroon;",
        tags$em(paste0(
          "BMPs in CAST are of several different varieties, including ",
          "Efficiencies, Land-Use Change, and Manure Transport. ",
          "This optimization tool is limited to Efficiency BMPs. ",
          "Greater load reductions can often be achieved ",
          "in CAST utilizing non-efficiency BMPs, such as Buffers."
        ))
      ),
      tags$li(style = "color: maroon;",
        tags$em(paste0(
          "This Beta version utilizes stored data for pre-solved optimization problems. ",
          "Future releases covering more BMP types may solve optimization problems on ",
          "the fly, requiring more time to generate results."
        ))
      ),
      tags$li(
        paste0(
          "This version includes \"Planning BMPs.\" ",
          "Consequently, some results here may not be available in CAST scenarios that are restricted ",
          "to \"Official BMPs\" only."
        )
      ),
      tags$li(
        paste0(
          "Geographic selection is limited to county-scale in the watershed."
        )
      ),
      tags$li(
        paste0(
          "The assumed per-acre cost estimate of each BMP comes from the \"watershed average\" cost ",
          "profile in CAST "
        ),
        tags$span(style = "color: black;",
                  HTML(paste0(
                    '(',
                    tags$a(
                      href = 'https://cast.chesapeakebay.net/Documentation/CostProfiles',
                      'https://cast.chesapeakebay.net/Documentation/CostProfiles'
                    ),
                    '). '
                  ))),
        paste0(
          "Future versions of this optimization tool will allow specification of your own cost profile, ",
          "which is a feature available in CAST itself."
        )
      ),
      tags$li(
        paste0(
          "Agriculture, Developed, and Natural sector load sources are ",
          "included (excluding \"Riparian Pasture Deposition\" and \"Stream Bed and Bank\"). ",
          "Wastewater and Septic sector loads are not included."
        )
      ),
      tags$li(
        paste0(
          "Because the base starting load in VICO does not contain ",
          "all of the load sources present in CAST, percent load reductions ",
          "obtained in VICO will not exactly match percentages obtained in CAST."
        )
      ),
      tags$li(
        paste0(
          "Base loading values are restricted to 2010 No-Action values ",
          "and were retrieved from CAST-2017d on 07/09/2019.")
                      )
    )
  )
  )
}
furtherdetailsnow <- function() {
  list(
    tags$div(style = "padding: 5px 10px 0px 10px;text-align: center;font-size: 14px;",
             tags$span(
               style = "color: black;",
               tags$strong("Further Details:")
             )),
    tags$div(
      style = "padding: 0px 22% 15px 22%;text-align: center;font-size: 14px;",
      tags$span(style = "color: black;",
                "For information regarding CAST, please visit the "),
      tags$span(
        style = "color: black;",
        tags$a(href = "https://cast.chesapeakebay.net/", "https://cast.chesapeakebay.net/")
      ),
      tags$span(style = "color: black;",
                " home page.")
    )
  )
}
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# OTA/VICO - User Interface (UI) Text Functions for Program Information Page
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# abouttop
# credits
# engineversion
# funding
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
abouttop <- function() {
  list(
    list(
      tags$div(style = "padding:2px 10px 5px 10px;text-align: center;font-size: 22px;",
               tags$span(
                 style = "color: black;",
                 tags$strong("VICO Beta-2")
               )
      ),
      tags$div(style = "padding: 0px 14% 5px 14%;text-align: center;font-size: 14px;",
               tags$span(
                 style = "color: black;",
                 tags$em("Developed by the Chesapeake Bay Program Office in collaboration with the Chesapeake Research Consortium.")
               )
      ),
      tags$div(style = "padding: 20px 14% 25px 14%;text-align: center;font-size: 14px;",
             tags$span(
               style = "color: black;",
               tags$strong(tags$em(
                 "\"One truly understands only what one can create.\" - Vico, Giambattista"
               ))
             )),
    tags$div(style = "padding: 0px 10px 5px 10px;",
             tags$span(
               style = "color: black;",
               paste0("The Visualization Interface for Chesapeake Optimization (VICO) ",
                      "is designed for use by the partners of the Chesapeake Bay Program (CBP), ",
                      "as well as the general public, as part of the Optimization Tool Development Project ",
                      "(U.S. EPA Assistance Agreement CB96350501)."
               )
             )
    )
  )
  )
}
credits <- function() {
  list(
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(
               style = "color: black;",
               tags$strong(
                 "Major Dependencies and Credits for Development and Implementation:"
               )
             )),
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(style = "color: black;",
                       tags$u("Overall:"))),
    tags$div(
      style = "padding: 0px 10px 5px 10px;text-align: left;",
      tags$span(
        style = "color: black;",
        "Amazon Web Services, Bitbucket, Git, GitLab, Jenkins, Slurm"
      )
    ),
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(style = "color: black;",
                       tags$u("Core Engine:"))),
    tags$div(
      style = "padding: 0px 10px 5px 10px;text-align: left;",
      tags$span(style = "color: black;",
                "Cloudpickle, IPOPT, NumPy, Pandas, Pyomo, Python")
    ),
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(style = "color: black;",
                       tags$u("Web Interface:"))),
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(style = "color: black;",
                       "R, NotePad++, Shiny"))
  )
}
engineversion <- function() {
  list(
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(style = "color: black;",
                       tags$strong("Version:"))),
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(
               style = "color: black;",
               paste0(
                 "Data for VICO Beta-2 are provided by version 0.1b2 of the optimization engine."
               )
             ))
  )
}
funding <- function() {
  list(
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(
               style = "color: black;",
               tags$strong("Funding Acknowledgments:")
             )),
    tags$div(style = "padding: 0px 10px 5px 10px;text-align: left;",
             tags$span(
               style = "color: black;",
               paste0(
                 "This project has been funded wholly or in part by the United States Environmental Protection Agency ",
                 "under assistance agreements CB96350501 to Chesapeake Research Consortium, Inc., and CB96325901 and ",
                 "CB96365601 to the University of Maryland Center for Environmental Science. The contents of this ",
                 "document do not necessarily reflect the views and policies of the Environmental Protection Agency, ",
                 "nor does the EPA endorse trade names or recommend the use of commercial products mentioned in this document."
               ))
    )
  )
}
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
# ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
