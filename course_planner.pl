% a prolog program for course planning, which I created to make it easier to plan my master
% to be used like this:
% ?- create_plans(10, 20, spring, 6, NumberOfPlans, Plans).

% course(id, name, ects, spring_slots, autumn_slots, dependencies)
course('01035','Matematik 2', 5, [['F2B']], [['E1A'], ['E2B']], []).
course('02220','Distribuerede systemer', 7.5, [['F1B']], [], []).
course('02582','Computational Data Analysis', 5, [['F4A']], [], ['02409', '02405']).
course('02405','Sandsynlighedsregning', 5, [['F4B']], [['E4B']], []).
course('02286','Logic in computer science, artificial intelligence and multi-agent systems', 7.5, [], [['E1A']], []).
course('02281','Data logic', 5, [['F2B']], [], []).
course('02409','Multivariate Statistics', 5, [], [['E1A']], []).
course('02451','Digital Signal Processing', 10, [], [['E5A','E5B']], ['01035','02405']).
course('02457','Non-Linear Signal Processing', 10, [], [['E1A','E1B']], ['02451']).
course('42435','Knowledge based Entrepreneurship', 5, [['F2A']], [['E2A']], []).
course('02285','Artificial intelligence and multi-agent systems', 7.5, [['F4A']], [], []).
course('02460','Advanced Machine Learning', 5, [['F1B']], [], ['02457']).

get_courses_spring(PreviousCourses, L) :-
    findall(Course/SpringSlots, (
        course(Course ,_,_, SpringSlots, _, CourseConstraints), 
        get_courses_condition(Course, SpringSlots, CourseConstraints, PreviousCourses)
    ), 
    L
).

get_courses_autumn(PreviousCourses, L) :-
    findall(Course/AutumnSlots, (
        course(Course, _,_,_, AutumnSlots, CourseConstraints), 
        get_courses_condition(Course, AutumnSlots, CourseConstraints, PreviousCourses)
    ), 
    L
).

get_courses_condition(Course, Slots, CourseConstraints, PreviousCourses) :-
    \+ length(Slots, 0), 
    \+ member(Course, PreviousCourses),
    (
        length(CourseConstraints, 0), !;
        member(Con, CourseConstraints), member(Con, PreviousCourses)
    ).

% subset(+MinECTS, +MaxECTS, +ECTS, +FilledSlots, -ECTSSum, +List, -SubsetList, -CourseSubsetList)
% MinECTS: min ects sum constraint
% MaxECTS: max ects sum constraint
% ECTS: current ects sum
% FilledSlots: current filled time slots
% ECTSSum: final ects sum for selected courses
% List: input list of courses to create subset of
% SubsetList: resulting subset of the input list of courses with its selected timeslot, -satisfying all the constraints
% CourseSubsetList: same as SubsetList, but without timeslots
subset(MinECTS,_,ECTSSum,_,ECTSSum,[],[],[]) :- ECTSSum >= MinECTS.
subset(MinECTS, MaxECTS, CurrECTSSum, FilledSlots, ECTSSum, [H/TimeSlots|T1], [H/TimeSlot|T2], [H|T3]) :-
    member(TimeSlot, TimeSlots),
    \+ (
        member(SubTimeSlot, TimeSlot),
        member(SubTimeSlot, FilledSlots)
    ),
    course(H,_,ECTS,_,_,_), 
    NewSum is CurrECTSSum + ECTS,
    NewSum =< MaxECTS, 
    append(FilledSlots, TimeSlot, NewFilledSlots),
    subset(MinECTS, MaxECTS, NewSum, NewFilledSlots, ECTSSum, T1, T2, T3).
subset(MinECTS, MaxECTS, CurrECTSSum, FilledSlots, ECTSSum, [_|T1], L2, L3) :-
    subset(MinECTS, MaxECTS, CurrECTSSum, FilledSlots, ECTSSum, T1, L2, L3).

create_plan(Season, MinECTS, MaxECTS, CurrPlan, CurrCourses, FinalPlan) :-
    (
        Season = spring, 
        get_courses_spring(CurrCourses, PossibleCourses), 
        \+ length(PossibleCourses, 0);
        Season = autumn,
        get_courses_autumn(CurrCourses, PossibleCourses)
    ),
    \+ length(PossibleCourses, 0),
    subset(MinECTS, MaxECTS, 0, [], ECTSSum, PossibleCourses, SeasonPlan, SelectedCourses),
    append(SelectedCourses, CurrCourses, NewCurrCourses),
    append(CurrPlan, [(SeasonPlan,ECTSSum)], NewPlan),
    (
        Season = spring, 
        create_plan(autumn, MinECTS, MaxECTS, NewPlan, NewCurrCourses, FinalPlan);
        Season = autumn,
        create_plan(spring, MinECTS, MaxECTS, NewPlan, NewCurrCourses, FinalPlan)
    ).
create_plan(_, _, _, FinalPlan, SelectedCourses, FinalPlan) :- 
    \+ bagof(X, (
        course(X,_,_,_,_,_), 
        \+ member(X, SelectedCourses)
    ), 
    _
).

create_plans(MinECTS, MaxECTS, StartSeason, MaxSemesters, NumberOfPlans, Plans) :-
    bagof(Plan, (
        create_plan(StartSeason, MinECTS, MaxECTS, [], [], Plan), 
        length(Plan, PlanLength), PlanLength =< MaxSemesters
    ), 
    Plans), 
    length(Plans, NumberOfPlans).

total_ects(X) :- findall(ECTS, course(_,_,ECTS,_,_,_), L), sum_list(L, X).
